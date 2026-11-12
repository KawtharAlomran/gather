import 'package:flutter/material.dart';

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
  void _endVoting() {
    final gathering = widget.gathering;
    if (gathering.votingEnded) return;
    setState(() => gathering.votingEnded = true);
    widget.onChanged?.call(gathering);
  }

  Future<void> _leave() async {
    if (!await confirmLeaveGathering(context) || !mounted) return;
    if (widget.onLeaveGathering == null) {
      AppMessage.show(
        context,
        message: 'Connect the leave action to your Home data source first.',
        type: MessageType.error,
      );
      return;
    }
    try {
      await widget.onLeaveGathering!(widget.gathering);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        AppMessage.show(
          context,
          message: 'Could not leave the gathering. Please try again.',
          type: MessageType.error,
        );
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
                    subtitle: gathering.votingEnded
                        ? 'Date voting ended'
                        : 'Planning continues',
                    onTap:
                        widget.onViewAttendance ??
                        () => openAttendance(
                          context,
                          widget.attendeeNames.isNotEmpty
                              ? widget.attendeeNames
                              : gathering.attendeeNames,
                          gatheringId: gathering.id,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Vote: Best Date')),
                            Text('Votes cast: ${gathering.totalVotes}'),
                          ],
                        ),
                        for (final option in gathering.dateOptions)
                          RadioListTile<String>(
                            value: option.id,
                            groupValue: gathering.selectedOptionId,
                            title: Text(option.label),
                            secondary: Text('Votes: ${option.votes}'),
                            onChanged: null,
                          ),
                        AppButton(
                          text: 'End Voting',
                          onPressed:
                              gathering.votingEnded ||
                                  gathering.dateOptions.isEmpty
                              ? null
                              : _endVoting,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (gathering.votingEnded)
                    AppButton(
                      text: 'Place voting',
                      onPressed: widget.onPlaceVoting,
                    )
                  else
                    AppButton(
                      text: 'Update My Preferences',
                      onPressed: widget.onUpdatePreferences,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
