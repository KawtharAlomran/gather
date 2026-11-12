import 'package:flutter/material.dart';

import '../models/gathering_model.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../shared_widgets/gathering_detail_widgets.dart';
import 'place_voting_screen.dart';

class InviteeGatheringPage extends StatelessWidget {
  final GatheringModel gathering;
  final VoidCallback onPlaceVoting;
  /// Parent must remove this gathering from the Home data source.
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

  Future<void> _leave(BuildContext context) async {
    if (!await confirmLeaveGathering(context) || !context.mounted) return;
    if (onLeaveGathering == null) {
      AppMessage.show(context, message: 'Connect the leave action to your Home data source first.', type: MessageType.error);
      return;
    }
    try {
      await onLeaveGathering!(gathering);
      if (context.mounted) Navigator.pop(context, true);
    } catch (_) {
      if (context.mounted) {
        AppMessage.show(context, message: 'Could not leave the gathering. Please try again.', type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = gathering.dateTime?.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            GatheringHeader(onLeave: () => _leave(context)),
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
                    subtitle: 'View attendees',
                    onTap: onViewAttendance ?? () => openAttendance(context, attendeeNames.isNotEmpty ? attendeeNames : gathering.attendeeNames, gatheringId: gathering.id),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 22),
                  if (gathering.status != 'confirmed' && gathering.dateTime == null) AppButton(
                    text: 'Place voting',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlaceVotingScreen()),
                      );
                    },
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
