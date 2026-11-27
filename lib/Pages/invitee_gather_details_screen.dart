// Displays gathering details for invited participants.
// Allows invitees to select their preferred date,
// view attendance, and leave the gathering.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vote_model.dart';
import '../data/repositories/vote_repository.dart';
import '../data/repositories/preference_repository.dart';

import '../models/gathering_model.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../shared_widgets/gathering_detail_widgets.dart';
import '../shared_widgets/gathering_vote_selection.dart';

class InviteeGatheringPage extends StatefulWidget {
  final GatheringModel gathering;
  // Kept for compatibility with existing navigation callers.
  final VoidCallback onPlaceVoting;
  final Future<void> Function(GatheringModel)? onLeaveGathering;
  final List<String> attendeeNames;
  final VoidCallback? onViewAttendance;

  const InviteeGatheringPage({
    super.key,
    required this.gathering,
    required this.onPlaceVoting,
    this.onLeaveGathering,
    this.attendeeNames = const [],
    this.onViewAttendance,
  });

  @override
  State<InviteeGatheringPage> createState() => _InviteeGatheringPageState();
}

class _InviteeGatheringPageState extends State<InviteeGatheringPage> {
  final _repository = VoteRepository();
  late Stream<List<Vote>> _votes;
  late Future<List<DateOptionModel>> _dateOptions;
  String? _selectedOptionId;
  bool _hasDraft = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateOptions = loadDateOptions(widget.gathering);
    _votes = _repository.watchVotes(widget.gathering.id, targetType: 'datetime');
  }

  Future<void> _saveVote(String? id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (_saving || widget.gathering.votingEnded) return;
    if (user == null) {
      AppMessage.show(context, message: 'Please sign in first.', type: MessageType.error);
      return;
    }
    setState(() => _saving = true);
    try {
      if (id == null) {
        await _repository.deleteVote(gatheringId: widget.gathering.id,
          userId: user.uid, targetType: 'datetime');
      } else {
        await _repository.saveVote(gatheringId: widget.gathering.id,
          userId: user.uid, targetId: id, targetType: 'datetime');
      }
      if (!mounted) return;
      setState(() => _hasDraft = false);
      AppMessage.show(context, message: id == null ? 'Your vote has been removed.' : 'Your date preference has been saved.');
    } catch (error) {
      debugPrint('Vote write failed: $error');
      if (mounted) AppMessage.show(context, message: 'Could not update vote: $error', type: MessageType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildVoting(GatheringModel gathering) {
    return FutureBuilder<List<DateOptionModel>>(
      future: _dateOptions,
      builder: (context, dates) {
        if (dates.hasError) return Text('Could not load date preferences: ${dates.error}');
        if (!dates.hasData) return const Center(child: CircularProgressIndicator());
        final available = dates.data!;
        if (available.isEmpty) return const Text('No date preferences available yet.');
        return StreamBuilder<List<Vote>>(
      stream: _votes,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Could not load votes: ${snapshot.error}');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final uid = FirebaseAuth.instance.currentUser?.uid;
        final counts = <String, int>{};
        String? savedOption;
        final validIds = available.map((o) => o.id).toSet();
        for (final vote in snapshot.data!) {
          if (!validIds.contains(vote.targetId) || !gathering.participantIds.contains(vote.userId)) continue;
          counts.update(vote.targetId, (n) => n + 1, ifAbsent: () => 1);
          if (vote.userId == uid) savedOption = vote.targetId;
        }
        final options = available.map((o) => DateOptionModel(
          id: o.id, label: o.label, dateTime: o.dateTime, votes: counts[o.id] ?? 0,
        )).toList();
        final selected = _hasDraft ? _selectedOptionId : savedOption;
        final enabled = !_saving && !gathering.votingEnded && uid != null;
        return Column(children: [
          GatheringVoteSelection(
            options: options,
            totalVotes: counts.values.fold<int>(0, (a, b) => a + b),
            selectedOptionId: selected,
            onSelected: (id) {
              if (enabled) setState(() { _selectedOptionId = id; _hasDraft = true; });
            },
            onSave: enabled && selected != null ? () => _saveVote(selected) : null,
          ),
          if (savedOption != null && !gathering.votingEnded)
            TextButton(onPressed: enabled ? () => _saveVote(null) : null,
              child: const Text('Remove my vote')),
        ]);
      },
    );
      },
    );
  }

  Future<void> _leave() async {
    if (!await confirmLeaveGathering(context) || !mounted) return;
    if (widget.onLeaveGathering == null) {
      AppMessage.show(context, message: 'Connect the leave action to your Home data source first.', type: MessageType.error);
      return;
    }
    try {
      await widget.onLeaveGathering!(widget.gathering);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) AppMessage.show(context, message: 'Could not leave the gathering. Please try again.', type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gathering = widget.gathering;
    final date = gathering.dateTime?.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final isPlanning = gathering.status != 'confirmed' && gathering.dateTime == null;

    return Scaffold(
      body: SafeArea(
        child: ListView(children: [
          GatheringHeader(onLeave: _leave),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Created by ${gathering.createdBy}', style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(gathering.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 18),
                GatheringAttendanceCard(
                  count: gathering.attendingCount,
                  subtitle: isPlanning ? 'Planning continues' : 'View attendees',
                  onTap: widget.onViewAttendance ?? () => openAttendance(
                    context,
                    widget.attendeeNames.isNotEmpty ? widget.attendeeNames : gathering.attendeeNames,
                    gatheringId: gathering.id,
                  ),
                ),
                const SizedBox(height: 16),
                if (isPlanning)
                  _buildVoting(gathering)
                else
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gather Date & Time'),
                        if (date != null) ...[
                          Text(localizations.formatFullDate(date)),
                          Text(localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))),
                        ] else
                          const Text('Date and time have not been confirmed.'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
