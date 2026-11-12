import 'package:flutter/material.dart';

import '../models/invitation_model.dart';
import '../models/user_model.dart';

import '../data/repositories/invitation_repository.dart';
import '../data/repositories/user_repository.dart';

import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_dialog.dart';
import '../shared_widgets/app_message.dart';
import '../theme/app_theme.dart';

class InvitationPage extends StatefulWidget {
  final InvitationRepository invitationRepository;
  final UserRepository userRepository;

  InvitationPage({
    super.key,
    InvitationRepository? invitationRepository,
    UserRepository? userRepository,
  }) : invitationRepository =
           invitationRepository ?? MockInvitationRepository(),
       userRepository = userRepository ?? MockUserRepository();

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  List<InvitationModel> _invitations = [];
  Map<String, User> _usersById = {};

  bool _isLoading = true;
  String? _error;
  String? _processingId;

  final Map<String, String> _gatheringTitles = {
    'gather_1': 'Cozy Soup Sunday',
    'gather_2': 'Nature Photography Hike',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load invitations and shared user data.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invitations = await widget.invitationRepository.getInvitations();

      final users = await widget.userRepository.getUsers();

      if (!mounted) return;

      setState(() {
        _invitations = invitations;
        _usersById = {for (final user in users) user.id: user};
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load invitations.';
        _isLoading = false;
      });
    }
  }

  // Accept or decline an invitation.
  Future<void> _updateInvitation(
    InvitationModel invitation,
    InvitationStatus newStatus,
  ) async {
    if (_processingId != null ||
        invitation.status != InvitationStatus.pending) {
      return;
    }

    setState(() {
      _processingId = invitation.id;
    });

    try {
      if (newStatus == InvitationStatus.accepted) {
        await widget.invitationRepository.acceptInvitation(invitation.id);
      } else {
        await widget.invitationRepository.declineInvitation(invitation.id);
      }

      final updated = await widget.invitationRepository.getInvitations();

      if (!mounted) return;

      setState(() {
        _invitations = updated;
      });

      AppMessage.show(
        context,
        message: newStatus == InvitationStatus.accepted
            ? 'Invitation accepted successfully!'
            : 'Invitation declined successfully!',
      );
    } catch (e) {
      if (!mounted) return;

      AppMessage.show(
        context,
        message: 'Something went wrong. Please try again.',
        type: MessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingId = null;
        });
      }
    }
  }

  // Show confirmation before declining.

  void _confirmDecline(InvitationModel invitation) {
    final title = _gatheringTitles[invitation.gatheringId] ?? 'this gathering';

    showDialog(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Do you want to decline the $title gathering?',
        confirmText: 'Decline',
        cancelText: 'Back',

        // Use button colors from the app theme.
        cancelColor: AppTheme.secondaryButtonColor,
        cancelTextColor: AppTheme.secondaryButtonTextColor,
        confirmColor: AppTheme.textColor,
        confirmTextColor: Theme.of(context).colorScheme.surface,

        onConfirm: () {
          Navigator.pop(dialogContext);
          _updateInvitation(invitation, InvitationStatus.declined);
        },
      ),
    );
  }

  // Build each invitation card using shared components.
  Widget _buildInvitationCard(InvitationModel invitation) {
    final inviter = _usersById[invitation.inviterId];
    final inviterName = inviter?.fullName ?? 'Unknown User';

    final gatheringTitle =
        _gatheringTitles[invitation.gatheringId] ?? 'Gathering';

    final isProcessing = _processingId == invitation.id;
    final isBusy = _processingId != null;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // TODO: Use a cached profile image when available.
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invited by',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inviterName,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.groups_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 24),

          Text(
            gatheringTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Decline',
                  fullWidth: true,
                  backgroundColor: AppTheme.secondaryButtonColor,
                  onPressed: isBusy ? null : () => _confirmDecline(invitation),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: AppButton(
                  text: 'Accept',
                  fullWidth: true,
                  isLoading: isProcessing,
                  onPressed: isBusy
                      ? null
                      : () => _updateInvitation(
                          invitation,
                          InvitationStatus.accepted,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingInvitations = _invitations
        .where((invitation) => invitation.status == InvitationStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Bottom navigation is handled by BottomNavigation.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                'Invitations',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 4),

              Text(
                'Your friends want to hang out!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 12),
                            AppButton(
                              text: 'Retry',
                              fullWidth: false,
                              onPressed: _loadData,
                            ),
                          ],
                        ),
                      )
                    : pendingInvitations.isEmpty
                    ? Center(
                        child: Text(
                          'No pending invitations.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: pendingInvitations.length,
                        itemBuilder: (context, index) {
                          final invitation = pendingInvitations[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildInvitationCard(invitation),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
