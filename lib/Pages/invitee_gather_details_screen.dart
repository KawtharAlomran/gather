// Displays gathering details for invited participants.
// Allows invitees to select their preferred date,
// view attendance, and leave the gathering.

import 'package:flutter/material.dart';

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
  String? _selectedOptionId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedOptionId = widget.gathering.selectedOptionId;
  }

  Future<void> _saveVote() async {
    final id = _selectedOptionId;
    if (id == null || _saving) return;
    setState(() => _saving = true);
    setState(() {
      widget.gathering.selectedOptionId = id;
      _saving = false;
    });
    AppMessage.show(context, message: 'Your date preference has been saved.');
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
                if (isPlanning && gathering.dateOptions.isNotEmpty)
                  GatheringVoteSelection(
                    options: gathering.dateOptions,
                    totalVotes: gathering.totalVotes,
                    selectedOptionId: _selectedOptionId,
                    onSelected: (id) => setState(() => _selectedOptionId = id),
                    onSave: _selectedOptionId == null || _saving ? null : _saveVote,
                  )
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
