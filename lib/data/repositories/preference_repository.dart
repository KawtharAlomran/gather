import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/preference_model.dart';
import '../../models/gathering_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PreferenceRepository {
  Future<void> savePreferences(
    PreferenceModel preferences,
  );

  Future<List<Map<String, double>>>
      getParticipantLocations(
    List<String> participantIds,
  );
}

class FirebasePreferenceRepository
    implements PreferenceRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

@override
Future<void> savePreferences(
  PreferenceModel preferences,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final ref = _firestore.collection('preferences').doc(user.uid);
    final batch = _firestore.batch();
    batch.set(ref, {
      ...preferences.toJson(),
      'userId': user.uid,
      'latitude': preferences.latitude,
      'longitude': preferences.longitude,
      'isCompleted': true,
    });
    final data = preferences.toJson();
    batch.set(ref.collection('availability').doc('dates'), {
      'dates': data['dates'],
      'times': data['times'],
    });
    await batch.commit();
  }
  @override
  Future<List<Map<String, double>>>
      getParticipantLocations(
    List<String> participantIds,
  ) async {
    final locations = <Map<String, double>>[];

    for (final userId in participantIds) {
      final doc = await _firestore
          .collection('preferences')
          .doc(userId)
          .get();

      final data = doc.data();

      if (data == null ||
          data['isCompleted'] != true ||
          data['latitude'] == null ||
          data['longitude'] == null) {
        continue;
      }

      locations.add({
        'latitude':
            (data['latitude'] as num).toDouble(),
        'longitude':
            (data['longitude'] as num).toDouble(),
      });
    }

    return locations;
  }
}
// Read only the shared date/time projection, never private location data.
// Legacy options remain readable so existing votes keep their original IDs.
Future<List<DateOptionModel>> loadDateOptions(GatheringModel gathering) async {
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final options = <String, DateOptionModel>{
    for (final option in gathering.dateOptions) option.id: option,
  };
  final start = formatGatheringDate(gathering.startDate);
  final end = formatGatheringDate(gathering.endDate);
  final records = await Future.wait(gathering.participantIds.toSet().map((id) async {
    final ref = firestore.collection('preferences').doc(id);
    final shared = await ref.collection('availability').doc('dates').get();
    // Existing users can read their own old preference until they save again.
    return shared.data() ?? (id == uid ? (await ref.get()).data() : null);
  }));
  for (final data in records) {
    if (data == null) continue;
    final times = data['times'] as Map? ?? const {};
    for (final raw in (data['dates'] as List? ?? const [])) {
      if (raw is! String) continue;
      final date = DateTime.tryParse(raw);
      if (date == null) continue;
      final day = formatGatheringDate(date)!;
      if (start != null && day.compareTo(start) < 0) continue;
      if (end != null && day.compareTo(end) > 0) continue;
      final period = (times[raw] ?? times[date.toIso8601String()] ?? '').toString().trim();
      final id = 'date_${day}_${Uri.encodeComponent(period.toLowerCase())}';
      options.putIfAbsent(id, () => DateOptionModel(
        id: id,
        label: period.isEmpty ? day : '$day - $period',
        // Preferences specify a period, not an exact meeting time.
        dateTime: DateTime.utc(date.year, date.month, date.day),
        votes: 0,
      ));
    }
  }
  return options.values.toList()..sort((a, b) {
    final result = a.dateTime.compareTo(b.dateTime);
    return result == 0 ? a.id.compareTo(b.id) : result;
  });
}
