import 'package:flutter/material.dart';

import '../models/gathering_model.dart';
import 'app_card.dart';

class SelectedDateTimeCard extends StatelessWidget {
  final GatheringModel gathering;
  const SelectedDateTimeCard({super.key, required this.gathering});

  @override
  Widget build(BuildContext context) {
    final selected = gathering.selectedDate;
    final period = gathering.selectedTimePeriod;
    final date = period != null ? selected : selected?.toLocal();
    final local = MaterialLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected date', style: Theme.of(context).textTheme.titleMedium),
          Text(date == null ? 'Not selected yet' : local.formatFullDate(date)),
          const SizedBox(height: 12),
          Text('Selected time', style: Theme.of(context).textTheme.titleMedium),
          Text(
            period ?? 'Not selected yet',
          ),
        ],
      ),
    );
  }
}
