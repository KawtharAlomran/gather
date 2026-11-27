import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/attendee_model.dart';
import '../../models/gathering_model.dart';

// Watch gathering participants and resolve their names.
Stream<List<AttendeeModel>> watchAttendees(
  String gatheringId, {
  List<String> fallbackNames = const [],
}) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('gatherings')
      .doc(gatheringId)
      .snapshots()
      .asyncMap((snapshot) async {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Gathering does not exist.');
        }

        // Get participant UIDs from the gathering.
        final participantIds = gatheringParticipantIds(data);

        // Support older gatherings without participantIds.
        if (participantIds == null) {
          final storedNames = (data['attendeeNames'] as List? ?? [])
              .whereType<String>()
              .where((name) => name.trim().isNotEmpty)
              .toList();
          final names = storedNames.isEmpty ? fallbackNames : storedNames;
          return [
            for (final entry in names.asMap().entries)
              AttendeeModel(
                id: 'legacy-${entry.key}',
                name: entry.value,
                gatheringId: gatheringId,
              ),
          ];
        }

        if (participantIds.isEmpty) {
          return <AttendeeModel>[];
        }

        // Read display names stored inside the gathering.
        final namesById = Map<String, dynamic>.from(
          data['participantNamesById'] as Map? ?? {},
        );

        final currentUser = FirebaseAuth.instance.currentUser;

        // Fetch missing names from the searchable user directory.
        final attendees = await Future.wait(
          participantIds.map((uid) async {
            String? name = _nonEmptyName(namesById[uid]);

            // Try the creator's stored name.
            if (name == null && uid == data['creatorId']) {
              name = _nonEmptyName(data['createdBy']);
            }

            // Try the current user's display name.
            if (name == null && uid == currentUser?.uid) {
              name = _nonEmptyName(currentUser?.displayName);
            }

            // Look up the participant in user_directory.
            if (name == null) {
              try {
                final directoryDocument = await firestore
                    .collection('user_directory')
                    .doc(uid)
                    .get();

                if (directoryDocument.exists) {
                  name = _nonEmptyName(
                    directoryDocument.data()?['displayName'],
                  );
                }
              } on FirebaseException catch (error) {
                // Keep the attendee visible if profile access fails.
                if (error.code != 'permission-denied') {
                  rethrow;
                }
              }
            }

            // The current user's name can be read privately.
            if (name == null && uid == currentUser?.uid) {
              try {
                final userDocument = await firestore
                    .collection('users')
                    .doc(uid)
                    .get();

                final userData = userDocument.data();

                name = [
                  _nonEmptyName(userData?['firstName']),
                  _nonEmptyName(userData?['lastName']),
                ].whereType<String>().join(' ').trim();

                if (name.isEmpty) {
                  name = null;
                }
              } on FirebaseException catch (error) {
                if (error.code != 'permission-denied') {
                  rethrow;
                }
              }
            }

            return AttendeeModel(
              id: uid,
              name:
                  name ??
                  (uid == currentUser?.uid ? 'You' : 'Name unavailable'),
              gatheringId: gatheringId,
            );
          }),
        );

        return attendees;
      });
}

// One-time read for screens using the existing interface.
Future<List<AttendeeModel>> loadAttendees(String gatheringId) {
  return watchAttendees(gatheringId).first;
}

String? _nonEmptyName(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;
