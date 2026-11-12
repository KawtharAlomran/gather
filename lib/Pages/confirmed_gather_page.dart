import 'package:flutter/material.dart';
import '../models/gathering_model.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../shared_widgets/gathering_detail_widgets.dart';

/// Standalone confirmed-details screen. Not connected to Home navigation.
class ConfirmedGatheringPage extends StatelessWidget {
  final GatheringModel gathering;
  final Future<void> Function(GatheringModel)? onLeaveGathering;
  const ConfirmedGatheringPage({super.key, required this.gathering, this.onLeaveGathering});

  Future<void> _leave(BuildContext context) async {
    if (!await confirmLeaveGathering(context) || !context.mounted) return;
    if (onLeaveGathering == null) {
      AppMessage.show(context, message: 'Connect the leave action to Home first.', type: MessageType.error);
      return;
    }
    try {
      await onLeaveGathering!(gathering);
      if (context.mounted) Navigator.pop(context, true);
    } catch (_) {
      if (context.mounted) AppMessage.show(context, message: 'Could not leave gathering.', type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = gathering.dateTime?.toLocal();
    final local = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(child: ListView(children: [
        GatheringHeader(onLeave: () => _leave(context)),
        Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Created by ${gathering.createdBy}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(gathering.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            if (date != null) Text('${local.formatMediumDate(date)} · ${local.formatTimeOfDay(TimeOfDay.fromDateTime(date))}'),
            if (gathering.place != null) Text(gathering.place!),
            const SizedBox(height: 14),
            GatheringAttendanceCard(count: gathering.attendingCount,
              subtitle: 'View attendees',
              onTap: () => openAttendance(context, gathering.attendeeNames, gatheringId: gathering.id)),
            const SizedBox(height: 12),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gather Date & Time', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(date == null ? 'Not confirmed' : local.formatFullDate(date)),
              if (date != null) Text(local.formatTimeOfDay(TimeOfDay.fromDateTime(date))),
            ])),
            const SizedBox(height: 12),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gather Place', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(gathering.place ?? 'Place not provided'),
            ])),
          ],
        )),
      ])),
    );
  }
}
