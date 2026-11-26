
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/invitation_model.dart';

// Defines the operations for managing invitations.
abstract class InvitationRepository {
  Future<List<InvitationModel>> getInvitations();

  Future<InvitationModel> acceptInvitation(String invitationId);

  Future<InvitationModel> declineInvitation(String invitationId);
}

// Firestore implementation of InvitationRepository.
class FirestoreInvitationRepository implements InvitationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreInvitationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('invitations');

  // Get the authenticated user's UID.
  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    return user.uid;
  }

  // Get invitations belonging to the current user only.
  @override
  Future<List<InvitationModel>> getInvitations() async {
    final userId = _currentUserId;

    final snapshot = await _invitations
        .where('inviteeId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => InvitationModel.fromFirestore(doc))
        .toList();
  }

  // Accept an invitation.
  @override
  Future<InvitationModel> acceptInvitation(
    String invitationId,
  ) async {
    return _updateStatus(
      invitationId,
      InvitationStatus.accepted,
    );
  }

  // Decline an invitation.
  @override
  Future<InvitationModel> declineInvitation(
    String invitationId,
  ) async {
    return _updateStatus(
      invitationId,
      InvitationStatus.declined,
    );
  }

  // Update an invitation only if it belongs to the current user.

Future<InvitationModel> _updateStatus(
  String invitationId,
  InvitationStatus newStatus,
) async {
  final userId = _currentUserId;
  final invitationRef = _invitations.doc(invitationId);

  return _firestore.runTransaction((transaction) async {
    // Read the invitation.
    final invitationSnapshot =
        await transaction.get(invitationRef);

    if (!invitationSnapshot.exists) {
      throw StateError('Invitation not found.');
    }

    final invitation =
        InvitationModel.fromFirestore(invitationSnapshot);

    // Only the recipient can respond.
    if (invitation.inviteeId != userId) {
      throw StateError(
        'You are not authorized to update this invitation.',
      );
    }

    // Only pending invitations can be updated.
    if (invitation.status != InvitationStatus.pending) {
      throw StateError(
        'Invitation has already been responded to.',
      );
    }

    // Read the gathering before performing any writes.
    DocumentReference<Map<String, dynamic>>? gatheringRef;

    if (newStatus == InvitationStatus.accepted) {
      gatheringRef = _firestore
          .collection('gatherings')
          .doc(invitation.gatheringId);

      final gatheringSnapshot =
          await transaction.get(gatheringRef);

      if (!gatheringSnapshot.exists) {
        throw StateError('Gathering not found.');
      }
    }

    // Update invitation status.
    transaction.update(invitationRef, {
      'status': newStatus.name,
    });

    // Add the user to the gathering only when accepted.
    if (newStatus == InvitationStatus.accepted) {
      transaction.update(gatheringRef!, {
        'participantIds': FieldValue.arrayUnion([userId]),
      });
    }

    return invitation.copyWith(status: newStatus);
  });
}

}

// Example usage:
//
// final repository = FirestoreInvitationRepository();
//
// final invitations = await repository.getInvitations();
//
// await repository.acceptInvitation('invitation_document_id');
//
// await repository.declineInvitation('invitation_document_id');
//
// Notes:
// - Uses Firebase Authentication to identify the current user.
// - Only retrieves invitations addressed to the current user.
// - Prevents accepting or declining other users' invitations.
// - Uses Firestore transactions to avoid duplicate responses.
// - Firestore Security Rules must also enforce these permissions.
