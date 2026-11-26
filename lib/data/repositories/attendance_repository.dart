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
      .map((snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('Gathering does not exist.');

    final ids = gatheringParticipantIds(data);
    if (ids == null) {
      final storedNames = (data['attendeeNames'] as List? ?? const [])
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList();
      final names = storedNames.isEmpty ? fallbackNames : storedNames;
      return [
        for (final entry in names.asMap().entries)
          AttendeeModel(id: 'legacy-${entry.key}', name: entry.value, gatheringId: gatheringId),
      ];
    }

    final namesById = data['participantNamesById'] as Map? ?? const {};
    final user = FirebaseAuth.instance.currentUser;
    return [
      for (final uid in ids)
        AttendeeModel(
          id: uid,
          gatheringId: gatheringId,
          name: _nonEmptyName(namesById[uid])
              ?? (uid == data['creatorId'] ? _nonEmptyName(data['createdBy']) : null)
              ?? (uid == user?.uid ? (_nonEmptyName(user?.displayName) ?? 'You') : 'Name unavailable'),
        ),
    ];
  });
}

String? _nonEmptyName(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

// One-time read for screens that already call the older repository interface.
Future<List<AttendeeModel>> loadAttendees(String gatheringId) =>
    watchAttendees(gatheringId).first;
