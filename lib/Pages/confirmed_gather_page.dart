import 'package:flutter/material.dart';
import '../models/gathering_model.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/gathering_detail_widgets.dart';

/// Standalone confirmed-details screen. Not connected to Home navigation.
class ConfirmedGatheringPage extends StatelessWidget {
  final GatheringModel gathering;
  const ConfirmedGatheringPage({super.key, required this.gathering});

  @override
  Widget build(BuildContext context) {
    final date = gathering.dateTime?.toLocal();
    final local = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(child: ListView(children: [

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
