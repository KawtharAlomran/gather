
import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus {
  pending,
  accepted,
  declined,
}

class InvitationModel {
  final String id;
  final String gatheringId;
  final String inviterId;
  final String inviteeId;
  final InvitationStatus status;
  final DateTime? createdAt;

  const InvitationModel({
    required this.id,
    required this.gatheringId,
    required this.inviterId,
    required this.inviteeId,
    this.status = InvitationStatus.pending,
    this.createdAt,
  });

  // Create an updated copy without modifying the original.
  InvitationModel copyWith({
    String? id,
    String? gatheringId,
    String? inviterId,
    String? inviteeId,
    InvitationStatus? status,
    DateTime? createdAt,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      gatheringId: gatheringId ?? this.gatheringId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Create an invitation from a Firestore document.
  factory InvitationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError('Invitation document does not exist.');
    }

    return InvitationModel(
      id: document.id,
      gatheringId: data['gatheringId'] as String,
      inviterId: data['inviterId'] as String,
      inviteeId: data['inviteeId'] as String,
      status: InvitationStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert the invitation into Firestore-compatible data.
  Map<String, dynamic> toFirestore() {
    return {
      'gatheringId': gatheringId,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}


// Notes:
// - The invitation ID is the Firestore document ID.
// - The inviterId identifies the sender.
// - The inviteeId identifies the recipient.
// - The default invitation status is pending.
// - createdAt uses a Firestore Timestamp.
// - copyWith supports immutable state updates.
// - Firestore handles local data caching on supported platforms.
