import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'NotificationPage.dart';
import 'create_gathering_screen.dart';

import '../data/repositories/gathering_details_repository.dart';
import '../models/gathering_model.dart';
import '../Navigation/gathering_navigation.dart';
import '../Navigation/BottomNavigation.dart';

import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../shared_widgets/app_search_field.dart';
import '../states/notification_read_state.dart';
import 'place_voting_screen.dart';
import 'time_preference_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  String? _streamUserId;
  final Map<String, List<String>> _participantIds = {};
  final Map<String, Stream<QuerySnapshot<Map<String, dynamic>>>> _voteStreams =
      {};

  final Map<String, Stream<QuerySnapshot<Map<String, dynamic>>>>
  _invitationStreams = {};

  Stream<QuerySnapshot<Map<String, dynamic>>> _pendingInvitationsFor(
    String gatheringId,
  ) {
    return _invitationStreams.putIfAbsent(
      gatheringId,
      () => FirebaseFirestore.instance
          .collection('invitations')
          .where('gatheringId', isEqualTo: gatheringId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _votesFor(String gatheringId, String targetType) {
    return _voteStreams.putIfAbsent(
      '$gatheringId:$targetType',
      () => FirebaseFirestore.instance
          .collection('votes')
          .where('gatheringId', isEqualTo: gatheringId)
          .where('targetType', isEqualTo: targetType)
          .snapshots(),
    );
  }

  int _planningProgress(
    GatheringModel gathering,
    QuerySnapshot<Map<String, dynamic>> votes,
    QuerySnapshot<Map<String, dynamic>> invitations,
  ) {
    final participants = (_participantIds[gathering.id] ?? []).toSet();
    final expectedParticipants = {
      ...participants,
      if (!gathering.votingEnded) ...invitations.docs
          .map((doc) => doc.data()['inviteeId'])
          .whereType<String>()
          .where((id) => id.trim().isNotEmpty),
    };
    if (expectedParticipants.isEmpty) return 0;
    final voters = <String>{};
    for (final doc in votes.docs) {
      final data = doc.data();
      final uid = data['userId'];
      if (uid is String &&
          participants.contains(uid) &&
          data['targetId'] is String &&
          (data['targetId'] as String).trim().isNotEmpty) {
        voters.add(uid);
      }
    }
    return (100 * voters.length / expectedParticipants.length).round();
  }

  Stream<List<GatheringModel>>? _gatheringsStream;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Listen to gatherings belonging to the current user.
  // Cache the stream to avoid reconnecting on each rebuild.
  Stream<List<GatheringModel>> _streamForUser(String userId) {
    if (_gatheringsStream == null || _streamUserId != userId) {
      _streamUserId = userId;
      _participantIds.clear();
      _voteStreams.clear();
      _invitationStreams.clear();
      _gatheringsStream = _watchGatherings(userId);
    }
    return _gatheringsStream!;
  }

  Stream<List<GatheringModel>> _watchGatherings(String userId) {
    return FirebaseFirestore.instance
        .collection('gatherings')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final ids = snapshot.docs.map((doc) => doc.id).toSet();
          _participantIds.removeWhere((id, _) => !ids.contains(id));
          _voteStreams.removeWhere((key, _) => !ids.contains(key.split(':').first));
          _invitationStreams.removeWhere((id, _) => !ids.contains(id));
          return snapshot.docs.map((document) {
            _participantIds[document.id] =
                gatheringParticipantIds(document.data()) ?? [];
            try {
              return GatheringModel.fromJson({
                ...document.data(),
                'id': document.id,
              });
            } catch (error) {
              debugPrint('Invalid gathering ${document.id}: $error');
              rethrow;
            }
          }).toList();
        });
  }

  @override
  void initState() {
    super.initState();
    NotificationReadState.load();
  }

  // Leave a gathering using the existing repository.
  Future<void> _leaveGathering(GatheringModel gathering) async {
    try {
      await leaveGathering(gathering.id);

      if (!mounted) return;

      AppMessage.show(context, message: 'You left the gathering.');
    } catch (e) {
      if (!mounted) return;

      debugPrint('Leave gathering error: $e');

      AppMessage.show(
        context,
        message: 'Unable to leave gathering.',
        type: MessageType.error,
      );
    }
  }

  // Open gathering details.
  void _openGathering(GatheringModel gathering) {
    final userId = currentUserId;

    if (userId == null) return;

    openGatheringDetails(
      context: context,
      gathering: gathering,
      currentUserId: userId,
      onPlaceVoting: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PlaceVotingScreen(gatheringId: gathering.id),
          ),
        );
      },
      onUpdatePreferences: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) =>
                TimePreferenceScreen.fromGatheringModel(gathering: gathering),
          ),
        );
      },
      onChanged: (_) {
        if (mounted) {
          setState(() {});
        }
      },
      onLeaveGathering: _leaveGathering,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<Set<String>>(
              valueListenable: NotificationReadState.unreadKeys,
              builder: (context, unread, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (unread.isNotEmpty)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              BottomNavigation.selectTab(context, 2);
            },
          ),
        ],
      ),

      body: userId == null
          ? const Center(child: Text('Please log in to view your gatherings.'))
          : StreamBuilder<List<GatheringModel>>(
              stream: _streamForUser(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Failed to load gatherings: ${snapshot.error}');
                  final error = snapshot.error;
                  final message =
                      error is FirebaseException &&
                          error.code == 'permission-denied'
                      ? 'Firestore access denied. Check gathering rules.'
                      : 'Failed to load gatherings. Check Debug Console.';
                  return Center(child: Text(message));
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snapshot.data ?? <GatheringModel>[];

                final filtered = all.where((gathering) {
                  return gathering.title.toLowerCase().contains(
                    _search.toLowerCase(),
                  );
                }).toList();

                final confirmed = filtered.where((g) {
                  return g.status == 'confirmed' || g.dateTime != null;
                }).toList();

                final planning = filtered.where((g) {
                  return g.status != 'confirmed' && g.dateTime == null;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Good morning 👋', style: theme.textTheme.bodySmall),

                    Text(
                      'Hey, welcome back!',
                      style: theme.textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 20),

                    AppSearchField(
                      hintText: 'Search gatherings...',
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    Text('Upcoming Events', style: theme.textTheme.titleMedium),

                    const SizedBox(height: 12),

                    if (confirmed.isEmpty)
                      const Text('No confirmed gatherings'),

                    if (confirmed.isNotEmpty)
                      SizedBox(
                        height: 175,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: confirmed.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final gathering = confirmed[index];

                            return SizedBox(
                              width: 235,
                              child: AppCard(
                                onTap: () => _openGathering(gathering),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONFIRMED',
                                      style: theme.textTheme.labelSmall,
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      gathering.title,
                                      style: theme.textTheme.titleMedium,
                                      maxLines: 2,
                                    ),

                                    const Spacer(),

                                    if (gathering.dateTime != null)
                                      Text(
                                        MaterialLocalizations.of(context)
                                            .formatMediumDate(
                                              gathering.dateTime!.toLocal(),
                                            ),
                                      ),

                                    Text(
                                      gathering.place ?? 'Place not specified',
                                      maxLines: 1,
                                    ),

                                    Text(
                                      '${gathering.attendingCount} attending',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    Text(
                      'Planning in Progress',
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 12),

                    if (planning.isEmpty)
                      const Text('No gatherings in progress'),

                    for (final gathering in planning)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () => _openGathering(gathering),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gathering.title,
                                      style: theme.textTheme.titleMedium,
                                    ),

                                      StreamBuilder<
                                        QuerySnapshot<Map<String, dynamic>>
                                      >(
                                        key: ValueKey('${gathering.id}:${gathering.votingEnded}'),
                                        stream: _votesFor(gathering.id, gathering.votingEnded ? 'place' : 'datetime'),
                                        builder: (context, votes) {
                                          if (votes.hasError) {
                                            return const Text(
                                              'Unable to load voting progress',
                                            );
                                          }
                                          if (!votes.hasData) {
                                            return const LinearProgressIndicator();
                                          }
                                          return StreamBuilder<
                                            QuerySnapshot<Map<String, dynamic>>
                                          >(
                                            stream: _pendingInvitationsFor(
                                              gathering.id,
                                            ),
                                            builder: (context, invitations) {
                                              if (invitations.hasError) {
                                                debugPrint(
                                                  'Failed to load pending invitations: ${invitations.error}',
                                                );
                                                return const Text(
                                                  'Unable to load voting progress',
                                                );
                                              }
                                              if (!invitations.hasData) {
                                                return const LinearProgressIndicator();
                                              }
                                              final progress =
                                                  _planningProgress(
                                                    gathering,
                                                    votes.data!,
                                                    invitations.data!,
                                                  );
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${gathering.votingEnded ? 'Place voting' : 'Date & time voting'} · $progress%',
                                                  ),
                                                  const SizedBox(height: 5),
                                                  LinearProgressIndicator(
                                                    value: progress / 100,
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

      floatingActionButton: SizedBox(
        width: 165,
        child: AppButton(
          text: '+ New Gathering',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateGathering()),
            );
          },
        ),
      ),
    );
  }
}
