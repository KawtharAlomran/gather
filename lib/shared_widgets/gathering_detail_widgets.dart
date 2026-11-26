// Contains reusable UI components shared across gathering details pages.
// Ensures consistent design and reduces duplicated code
// for the header, attendance display, and confirmation dialog.

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'app_card.dart';
import 'app_dialog.dart';
import '../models/attendee_model.dart';
import '../data/repositories/attendance_repository.dart';

/// Set this to your own asset path after adding it to pubspec.yaml.
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
            errorBuilder: (_, _, _) => Container(
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
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: PopupMenuButton<String>(
              tooltip: 'Gathering options',
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
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
    body: gatheringId.isEmpty
        ? _attendanceList(fallbackNames)
        : _LiveAttendees(
            key: ValueKey(gatheringId),
            gatheringId: gatheringId,
            fallbackNames: fallbackNames,
          ),
  );
}

class _LiveAttendees extends StatefulWidget {
  final String gatheringId;
  final List<String> fallbackNames;

  const _LiveAttendees({
    super.key,
    required this.gatheringId,
    required this.fallbackNames,
  });

  @override
  State<_LiveAttendees> createState() => _LiveAttendeesState();
}

class _LiveAttendeesState extends State<_LiveAttendees> {
  late final _stream = watchAttendees(
    widget.gatheringId,
    fallbackNames: widget.fallbackNames,
  );

  @override
  Widget build(BuildContext context) => StreamBuilder<List<AttendeeModel>>(
    stream: _stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        debugPrint('Attendance read failed: ${snapshot.error}');
        final error = snapshot.error;
        if (error is FirebaseException &&
            (error.code == 'unavailable' || error.code == 'deadline-exceeded') &&
            widget.fallbackNames.isNotEmpty) {
          return Column(
            children: [
              const Text('Showing previously loaded names.'),
              Expanded(child: _attendanceList(widget.fallbackNames)),
            ],
          );
        }
        return const Center(child: Text('Could not load attendance.'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return _attendanceList(snapshot.data!.map((a) => a.name).toList());
    },
  );
}

Widget _attendanceList(List<String> names) {
  if (names.isEmpty) return const Center(child: Text('No attendee names available.'));
  return ListView.builder(
    itemCount: names.length,
    itemBuilder: (context, index) => ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(names[index]),
    ),
  );
}

void openAttendance(BuildContext context, List<String> names, {String gatheringId = ''}) {
  Navigator.push(context, MaterialPageRoute<void>(
    builder: (_) => GatheringAttendancePage(gatheringId: gatheringId, fallbackNames: names),
  ));
}
