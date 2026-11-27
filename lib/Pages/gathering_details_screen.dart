// Displays gathering details for the creator.
// Allows the creator to manage date voting, view attendance,
// and update gathering preferences.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vote_model.dart';
import '../data/repositories/vote_repository.dart';
import '../data/repositories/preference_repository.dart';

import '../models/gathering_model.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../shared_widgets/gathering_detail_widgets.dart';

class CreatorGatheringPage extends StatefulWidget {
  final GatheringModel gathering;
  final VoidCallback onPlaceVoting;
  final VoidCallback onUpdatePreferences;
  final VoidCallback? onViewAttendance;
  final ValueChanged<GatheringModel>? onChanged;
  /// Parent must remove this gathering from its Home data source.
  final Future<void> Function(GatheringModel)? onLeaveGathering;
  /// Supply actual attendee names from your repository; count alone is insufficient.
  final List<String> attendeeNames;

  const CreatorGatheringPage({
    super.key,
    required this.gathering,
    required this.onPlaceVoting,
    required this.onUpdatePreferences,
    this.onViewAttendance,
    this.onChanged,
    this.onLeaveGathering,
    this.attendeeNames = const [],
  });

  @override
  State<CreatorGatheringPage> createState() => _CreatorGatheringPageState();
}

class _CreatorGatheringPageState extends State<CreatorGatheringPage> {
  final _voteRepository = VoteRepository();
  late Stream<List<Vote>> _votes;
  late Future<List<DateOptionModel>> _dateOptions;
  bool _savingVote = false;

  @override
  void initState() {
    super.initState();
    _subscribeVotes();
  }

  void _subscribeVotes() {
    _dateOptions = loadDateOptions(widget.gathering);
    _votes = _voteRepository.watchVotes(widget.gathering.id, targetType: 'datetime');
  }

  @override
  void didUpdateWidget(covariant CreatorGatheringPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gathering.id != widget.gathering.id) _subscribeVotes();
  }

  Future<void> _changeVote(String? optionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _savingVote || widget.gathering.votingEnded) return;
    setState(() => _savingVote = true);
    try {
      if (optionId == null) {
        await _voteRepository.deleteVote(gatheringId: widget.gathering.id,
          userId: user.uid, targetType: 'datetime');
      } else {
        await _voteRepository.saveVote(gatheringId: widget.gathering.id,
          userId: user.uid, targetId: optionId, targetType: 'datetime');
      }
    } catch (error) {
      debugPrint('Vote write failed: $error');
      if (mounted) AppMessage.show(context, message: 'Could not update vote.', type: MessageType.error);
    } finally {
      if (mounted) setState(() => _savingVote = false);
    }
  }
Future<void> _endVoting() async {
  final gathering = widget.gathering;

  if (gathering.votingEnded) return;

  try {
    await FirebaseFirestore.instance
        .collection('gatherings')
        .doc(gathering.id)
        .update({
      'votingEnded': true,
    });

    if (!mounted) return;

    setState(() {
      gathering.votingEnded = true;
    });

    widget.onChanged?.call(gathering);

  } catch (e) {
    if (!mounted) return;

    AppMessage.show(
      context,
      message: 'Could not end voting: $e',
      type: MessageType.error,
    );
  }
}
  Future<void> _leave() async {
    if (!await confirmLeaveGathering(context) || !mounted) return;
    if (widget.onLeaveGathering == null) {
      AppMessage.show(context, message: 'Connect the leave action to your Home data source first.', type: MessageType.error);
      return;
    }
    try {
      await widget.onLeaveGathering!(widget.gathering);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        AppMessage.show(context, message: 'Could not leave the gathering. Please try again.', type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gathering = widget.gathering;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            GatheringHeader(onLeave: _leave),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Created by You', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(gathering.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 18),
                  GatheringAttendanceCard(
                    count: gathering.attendingCount,
                    subtitle: gathering.votingEnded ? 'Date voting ended' : 'Planning continues',
                    onTap: widget.onViewAttendance ??
                        () => openAttendance(context, widget.attendeeNames.isNotEmpty ? widget.attendeeNames : gathering.attendeeNames, gatheringId: gathering.id),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: FutureBuilder<List<DateOptionModel>>(
                      future: _dateOptions,
                      builder: (context, dates) {
                        if (dates.hasError) return Text('Could not load date preferences: ${dates.error}');
                        if (!dates.hasData) return const Center(child: CircularProgressIndicator());
                        final options = dates.data!;
                        if (options.isEmpty) return const Text('No date preferences available yet.');
                        return StreamBuilder<List<Vote>>(
                      stream: _votes,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Could not load votes.');
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        final counts = <String, int>{};
                        String? selected;
                        final optionIds = options.map((o) => o.id).toSet();
                        for (final vote in snapshot.data!) {
                          if (!optionIds.contains(vote.targetId) || !gathering.participantIds.contains(vote.userId)) continue;
                          counts.update(vote.targetId, (n) => n + 1, ifAbsent: () => 1);
                          if (vote.userId == uid) selected = vote.targetId;
                        }
                        final total = counts.values.fold<int>(0, (a, b) => a + b);
                        final canVote = uid != null && !_savingVote && !gathering.votingEnded;
                        return Column(children: [
                          Row(children: [
                            const Expanded(child: Text('Vote: Best Date')),
                            Text('Votes cast: $total'),
                          ]),
                          for (final option in options)
                            RadioListTile<String>(
                              value: option.id,
                              groupValue: selected,
                              title: Text(option.label),
                              secondary: Text('Votes: ${counts[option.id] ?? 0}'),
                              onChanged: canVote ? _changeVote : null,
                            ),
                          if (selected != null)
                            TextButton(onPressed: canVote ? () => _changeVote(null) : null,
                              child: const Text('Remove my vote')),
                          AppButton(
                            text: 'End Voting',
                            onPressed: gathering.votingEnded || options.isEmpty || _savingVote
                                ? null : () {
                                  for (final option in options) {
                                    option.votes = counts[option.id] ?? 0;
                                  }
                                  gathering.selectedOptionId = selected;
                                  _endVoting();
                                },
                          ),
                        ]);
                      },
                    );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (gathering.status != 'confirmed' && gathering.dateTime == null && gathering.votingEnded)
                    AppButton(text: 'Place voting', onPressed: widget.onPlaceVoting)
                  else if (gathering.status != 'confirmed' && gathering.dateTime == null)
                    AppButton(text: 'Update My Preferences', onPressed: widget.onUpdatePreferences),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
