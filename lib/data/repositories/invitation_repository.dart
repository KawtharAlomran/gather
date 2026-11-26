
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

  // Firestore invitations collection.
  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('invitations');

  // Firestore gatherings collection.
  CollectionReference<Map<String, dynamic>> get _gatherings =>
      _firestore.collection('gatherings');

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
        .map(
          (doc) => InvitationModel.fromFirestore(doc),
        )
        .toList();
  }

  // Accept an invitation and join its gathering.
  @override
  Future<InvitationModel> acceptInvitation(
    String invitationId,
  ) async {
    return _updateStatus(
      invitationId,
      InvitationStatus.accepted,
    );
  }

  // Decline an invitation without joining the gathering.
  @override
  Future<InvitationModel> declineInvitation(
    String invitationId,
  ) async {
    return _updateStatus(
      invitationId,
      InvitationStatus.declined,
    );
  }

  // Update an invitation using a Firestore transaction.
  Future<InvitationModel> _updateStatus(
    String invitationId,
    InvitationStatus newStatus,
  ) async {
    final userId = _currentUserId;
    final invitationRef = _invitations.doc(invitationId);

    return _firestore.runTransaction((transaction) async {
      // Read the invitation document.
      final invitationSnapshot =
          await transaction.get(invitationRef);

      if (!invitationSnapshot.exists) {
        throw StateError('Invitation not found.');
      }

      final invitation =
          InvitationModel.fromFirestore(invitationSnapshot);

      // Only the invitation recipient can respond.
      if (invitation.inviteeId != userId) {
        throw StateError(
          'You are not authorized to update this invitation.',
        );
      }

      // Only pending invitations can be accepted or declined.
      if (invitation.status != InvitationStatus.pending) {
        throw StateError(
          'Invitation has already been responded to.',
        );
      }

      // Read the gathering before performing any writes.
      DocumentReference<Map<String, dynamic>>? gatheringRef;

      if (newStatus == InvitationStatus.accepted) {
        gatheringRef = _gatherings.doc(invitation.gatheringId);

        final gatheringSnapshot =
            await transaction.get(gatheringRef);

        if (!gatheringSnapshot.exists) {
          throw StateError('Gathering not found.');
        }
      }

      // Update the invitation status.
      transaction.update(invitationRef, {
        'status': newStatus.name,
      });

      // Add the user to the gathering when accepted.
      if (newStatus == InvitationStatus.accepted) {
        transaction.update(gatheringRef!, {
          'participantIds': FieldValue.arrayUnion([userId]),
        });
      }

      // Return the updated invitation model.
      return invitation.copyWith(
        status: newStatus,
      );
    });
  }
}

// --------------------------------------------------
// Example usage
// --------------------------------------------------

// final repository = FirestoreInvitationRepository();
//
// // Get the current user's invitations.
// final invitations = await repository.getInvitations();
//
// // Accept an invitation and join the gathering.
// await repository.acceptInvitation('invitation_document_id');
//
// // Decline an invitation.
// await repository.declineInvitation('invitation_document_id');
//
// --------------------------------------------------
// Notes
// --------------------------------------------------

// - Uses Firebase Authentication to identify the current user.
// - Retrieves invitations belonging to the authenticated user.
// - Accept updates the invitation status to "accepted".
// - Accept adds the user UID to gathering participantIds.
// - Decline updates the invitation status to "declined" only.
// - Firestore transactions update related documents atomically.
// - arrayUnion prevents duplicate participant IDs.
// - Firestore Security Rules must authorize these operations.


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
