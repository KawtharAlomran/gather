import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/attendee_model.dart';
import '../../models/gathering_model.dart';

Stream<List<AttendeeModel>> watchAttendees(
  String gatheringId, {
  List<String> fallbackNames = const [],
}) {
  return FirebaseFirestore.instance
      .collection('gatherings')
      .doc(gatheringId)
      .snapshots()
      .asyncMap((snapshot) async {
    final data = snapshot.data();

    if (data == null) {
      throw StateError('Gathering does not exist.');
    }

    final ids = gatheringParticipantIds(data);

    // Support older gathering documents.
    if (ids == null) {
      final storedNames = (data['attendeeNames'] as List? ?? [])
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList();

      final names =
          storedNames.isEmpty ? fallbackNames : storedNames;

      return [
        for (final entry in names.asMap().entries)
          AttendeeModel(
            id: 'legacy-${entry.key}',
            name: entry.value,
            gatheringId: gatheringId,
          ),
      ];
    }

    final user = FirebaseAuth.instance.currentUser;

    // Retrieve each participant's name from Firebase.
    return Future.wait(
      ids.map((uid) async {
        String? name;

        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('user_directory')
              .doc(uid)
              .get();

          name = _nonEmptyName(
            userDoc.data()?['displayName'],
          );
        } on FirebaseException catch (e) {
          // Keep the attendance list available if a name
          // cannot be retrieved.
          print('Cannot load attendee $uid: ${e.code}');
        }

        return AttendeeModel(
          id: uid,
          gatheringId: gatheringId,
          name: name ??
              (uid == user?.uid
                  ? (_nonEmptyName(user?.displayName) ?? 'You')
                  : 'Name unavailable'),
        );
      }),
    );
  });
}

String? _nonEmptyName(Object? value) =>
    value is String && value.trim().isNotEmpty
        ? value.trim()
        : null;

// One-time read for screens using the older interface.
Future<List<AttendeeModel>> loadAttendees(String gatheringId) =>
    watchAttendees(gatheringId).first;