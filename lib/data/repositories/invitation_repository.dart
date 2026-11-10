
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/invitation_model.dart';

// Defines the operations for managing invitations.
abstract class InvitationRepository {
  Future<List<InvitationModel>> getInvitations();

  Future<InvitationModel> acceptInvitation(String invitationId);

  Future<InvitationModel> declineInvitation(String invitationId);
}

// Mock implementation using local JSON data.
class MockInvitationRepository implements InvitationRepository {
  List<InvitationModel>? _invitations;

  // Load invitations from JSON only once per repository instance.
  Future<void> _loadInvitations() async {
    if (_invitations != null) return;

    final jsonString = await rootBundle.loadString(
      'lib/data/invitations.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _invitations = jsonData
        .map(
          (item) => InvitationModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Return the current list of invitations.
  @override
  Future<List<InvitationModel>> getInvitations() async {
    await _loadInvitations();

    return List.unmodifiable(_invitations!);
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

  // Update the invitation status in memory.
  Future<InvitationModel> _updateStatus(
    String invitationId,
    InvitationStatus status,
  ) async {
    await _loadInvitations();

    final index = _invitations!.indexWhere(
      (invitation) => invitation.id == invitationId,
    );

    if (index == -1) {
      throw StateError('Invitation not found: $invitationId');
    }

    final invitation = _invitations![index];

    if (invitation.status != InvitationStatus.pending) {
      throw StateError('Invitation has already been responded to.');
    }

    final updatedInvitation = invitation.copyWith(
      status: status,
    );

    _invitations![index] = updatedInvitation;

    return updatedInvitation;
  }
}

// Example usage:
//
// final repository = MockInvitationRepository();
//
// final invitations = await repository.getInvitations();
//
// final accepted = await repository.acceptInvitation('inv_1');
//
// final declined = await repository.declineInvitation('inv_2');
//
// Notes:
// - Invitation data is loaded from lib/data/invitations.json.
// - JSON data is loaded once per repository instance.
// - Accepting or declining updates the in-memory list.
// - Changes are not persisted after the repository is recreated.
// - The repository can be used with BLoC, Cubit, or Provider.
