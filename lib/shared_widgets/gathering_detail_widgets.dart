import 'package:flutter/material.dart';
import 'app_card.dart';
import 'app_dialog.dart';
import '../models/attendee_model.dart';
import '../data/repositories/attendance_repository.dart';

const String gatheringHeaderAsset = 'assets/images/background.png';

class GatheringHeader extends StatelessWidget {
  final Future<void> Function() onLeave;
  const GatheringHeader({super.key, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            gatheringHeaderAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: PopupMenuButton<String>(
              tooltip: 'Gathering options',
              icon: const Icon(Icons.more_vert),
              color: Theme.of(context).colorScheme.surface,
              onSelected: (value) {
                if (value == 'leave') onLeave();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'leave', child: Text('Leave Gathering')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns true only after the user confirms leaving.
Future<bool> confirmLeaveGathering(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppDialog(
          title: 'Leave Gathering?',
          message: 'Are you sure you want to leave this gathering?',
          confirmText: 'Leave',
          onConfirm: () => Navigator.pop(dialogContext, true),
        ),
      ) ??
      false;
}

class GatheringAttendanceCard extends StatelessWidget {
  final int count;
  final String subtitle;
  final VoidCallback onTap;
  const GatheringAttendanceCard({
    super.key,
    required this.count,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count Attending', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      );
}

class GatheringAttendancePage extends StatelessWidget {
  final String gatheringId;
  final List<String> fallbackNames;
  const GatheringAttendancePage({super.key, required this.gatheringId, this.fallbackNames = const []});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Attending')),
    body: FutureBuilder<List<AttendeeModel>>(
      future: loadAttendees(gatheringId),
      builder: (context, snapshot) {
        final names = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!.map((a) => a.name).toList()
            : fallbackNames;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (names.isEmpty) return const Center(child: Text('No attendee names available.'));
        return ListView.builder(
          itemCount: names.length,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(names[index]),
          ),
        );
      },
    ),
  );
}

void openAttendance(BuildContext context, List<String> names, {String gatheringId = ''}) {
  Navigator.push(context, MaterialPageRoute<void>(
    builder: (_) => GatheringAttendancePage(gatheringId: gatheringId, fallbackNames: names),
  ));
}
