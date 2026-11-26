import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/preference_model.dart';
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

    await _firestore
        .collection('preferences')
        .doc(user.uid)
        .set({
      ...preferences.toJson(),
      'userId': user.uid,
      'latitude': preferences.latitude,
      'longitude': preferences.longitude,
      'isCompleted': true,
    });
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