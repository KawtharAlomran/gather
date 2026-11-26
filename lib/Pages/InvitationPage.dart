
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';

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
           invitationRepository ?? FirestoreInvitationRepository(),
       userRepository = userRepository ?? FirebaseUserRepository();

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  List<InvitationModel> _invitations = [];
  Map<String, User> _usersById = {};

  bool _isLoading = true;
  String? _error;
  String? _processingId;

  Map<String, String> _gatheringTitles = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load invitations from Firestore and users from temporary repository.
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invitations =
          await widget.invitationRepository.getInvitations();

      // Invitation access is separate from access to profile/gathering data.
      // Read optional display details individually, without failing the list.
      final userIds = invitations.map((i) => i.inviterId).toSet();
      final gatheringIds = invitations.map((i) => i.gatheringId).toSet();
      final users = <String, User>{};
      final titles = <String, String>{};

      await Future.wait([
        for (final id in userIds)
          () async {
            try {
              final user = await widget.userRepository.getUserById(id);
              if (user != null) users[id] = user;
            } catch (e) {
              debugPrint('Cannot load inviter $id: $e');
            }
          }(),
        for (final id in gatheringIds)
          () async {
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('gatherings').doc(id).get();
              final title = doc.data()?['title'];
              if (title is String && title.isNotEmpty) titles[id] = title;
            } catch (e) {
              debugPrint('Cannot load gathering $id: $e');
            }
          }(),
      ]);

      if (!mounted) return;

      setState(() {
        _invitations = invitations;
        _usersById = users;
        _gatheringTitles = titles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Invitation loading error: $e');

      setState(() {
        _error = 'Unable to load invitations.';
        _isLoading = false;
      });
    }
  }

  // Accept or decline an invitation in Firestore.
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
        await widget.invitationRepository.acceptInvitation(
          invitation.id,
        );
      } else {
        await widget.invitationRepository.declineInvitation(
          invitation.id,
        );
      }

      final updated =
          await widget.invitationRepository.getInvitations();

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

      debugPrint('Invitation update error: $e');

      AppMessage.show(
        context,
        message: 'Unable to update invitation. Please try again.',
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

  // Show confirmation dialog before declining.
  void _confirmDecline(InvitationModel invitation) {
    final title =
        _gatheringTitles[invitation.gatheringId] ??
        'this gathering';

    showDialog(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Do you want to decline the $title gathering?',
        confirmText: 'Decline',
        cancelText: 'Back',
        cancelColor: AppTheme.secondaryButtonColor,
        cancelTextColor: AppTheme.secondaryButtonTextColor,
        confirmColor: AppTheme.textColor,
        confirmTextColor:
            Theme.of(context).colorScheme.surface,
        onConfirm: () {
          Navigator.pop(dialogContext);
          _updateInvitation(
            invitation,
            InvitationStatus.declined,
          );
        },
      ),
    );
  }

  // Build invitation card using shared components.
  Widget _buildInvitationCard(InvitationModel invitation) {
    final inviter = _usersById[invitation.inviterId];

    final inviterName = inviter?.fullName ?? 'Gather! member';

    final gatheringTitle =
        _gatheringTitles[invitation.gatheringId] ??
        'Gathering';

    final isProcessing = _processingId == invitation.id;
    final isBusy = _processingId != null;

    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // TODO: Replace with cached profile image.
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invited by',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inviterName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.groups_outlined,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 24),

          Text(
            gatheringTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Decline',
                  fullWidth: true,
                  backgroundColor:
                      AppTheme.secondaryButtonColor,
                  foregroundColor:
                      AppTheme.secondaryButtonTextColor,
                  onPressed: isBusy
                      ? null
                      : () => _confirmDecline(invitation),
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
    final currentUser = FirebaseAuth.instance.currentUser;

    final pendingInvitations = _invitations
        .where(
          (invitation) =>
              invitation.status == InvitationStatus.pending,
        )
        .toList();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // BottomNavigation is managed by the parent widget.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                'Invitations',
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 4),

              Text(
                'Your friends want to hang out!',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: currentUser == null
                    ? const Center(
                        child: Text(
                          'Please log in to view your invitations.',
                        ),
                      )
                    : _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
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
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: pendingInvitations.isEmpty
                                      ? 1
                                      : pendingInvitations.length,
                                  itemBuilder: (context, index) {
                                    if (pendingInvitations.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 80,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No pending invitations.',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ),
                                      );
                                    }

                                    final invitation =
                                        pendingInvitations[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _buildInvitationCard(invitation),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
