import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/preference_model.dart';
import '../../models/gathering_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

abstract class PreferenceRepository {
  Future<void> savePreferences(PreferenceModel preferences, {String? gatheringId});

  Future<List<Map<String, double>>> getParticipantLocations(
    List<String> participantIds, {String? gatheringId}
  );
}

class FirebasePreferenceRepository implements PreferenceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> savePreferences(PreferenceModel preferences, {String? gatheringId}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final ref = gatheringId == null
        ? _firestore.collection('preferences').doc(user.uid)
        : _firestore.collection('gatherings').doc(gatheringId).collection('preferences').doc(user.uid);
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

  Future<PreferenceModel?> getMyPreferences({String? gatheringId}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final snapshot = await (gatheringId == null
        ? _firestore.collection('preferences').doc(user.uid)
        : _firestore.collection('gatherings').doc(gatheringId).collection('preferences').doc(user.uid)).get();

    final data = snapshot.data();

    if (data == null) return null;

    return PreferenceModel.fromJson(data);
  }

  @override
  Future<List<Map<String, double>>> getParticipantLocations(
    List<String> participantIds, {String? gatheringId}
  ) async {
    final locations = <Map<String, double>>[];

    for (final userId in participantIds) {
      final doc = await (gatheringId == null
          ? _firestore.collection('preferences').doc(userId)
          : _firestore.collection('gatherings').doc(gatheringId).collection('preferences').doc(userId)).get();

      final data = doc.data();

      if (data == null ||
          data['isCompleted'] != true ||
          data['latitude'] == null ||
          data['longitude'] == null) {
        continue;
      }

      locations.add({
        'latitude': (data['latitude'] as num).toDouble(),
        'longitude': (data['longitude'] as num).toDouble(),
      });
    }

    return locations;
  }
}

// Read only the shared date/time projection, never private location data.
// Legacy options remain readable so existing votes keep their original IDs.
Future<List<DateOptionModel>> loadDateOptions(GatheringModel gathering) async {
  if (gathering.votingEnded && gathering.selectedDate != null) {
    return gathering.dateOptions;
  }
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final options = <String, DateOptionModel>{
    for (final option in gathering.dateOptions) option.id: option,
  };
  final start = formatGatheringDate(gathering.startDate);
  final end = formatGatheringDate(gathering.endDate);
  final records = await Future.wait(
    gathering.participantIds.toSet().map((id) async {
      final ref = firestore.collection('gatherings').doc(gathering.id).collection('preferences').doc(id);
      final shared = await ref.collection('availability').doc('dates').get();
      // Existing users can read their own old preference until they save again.
      return shared.data() ?? (id == uid ? (await ref.get()).data() : null);
    }),
  );
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
      final period = normalizeTimePeriod(times[raw] ?? times[DateTime(date.year, date.month, date.day).toIso8601String()]);
      if (period == null) continue;
      final id = 'date_${day}_${Uri.encodeComponent(period.toLowerCase())}';
      options.putIfAbsent(
        id,
        () => DateOptionModel(
          id: id,
          label: '$day - $period',
          storedTimePeriod: period,
          // Preferences specify a period, not an exact meeting time.
          dateTime: DateTime.utc(date.year, date.month, date.day),
          votes: 0,
        ),
      );
    }
  }
  return options.values.toList()..sort((a, b) {
    final result = a.dateTime.compareTo(b.dateTime);
    return result == 0 ? a.id.compareTo(b.id) : result;
  });
}
