import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/notification_model.dart';
import '../shared_widgets/app_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationModel>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _loadNotifications();
  }

  Future<List<NotificationModel>> _loadNotifications() async {
    final data = await rootBundle.loadString('lib/data/notification.json');

    return (jsonDecode(data) as List)
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _reloadNotifications() async {
    final reload = _loadNotifications();

    setState(() {
      _notifications = reload;
    });

    try {
      await reload;
    } catch (error, stackTrace) {
      debugPrint('Failed to reload notifications: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 48),
                const Center(child: Text('Unable to load notifications.')),
                Center(
                  child: TextButton(
                    onPressed: _reloadNotifications,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _reloadNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                for (final notification in snapshot.data!)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(notification.heading)),
                            Text(timeAgo(notification.date)),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  snapshot.data!.remove(notification);
                                });
                              },
                              tooltip: 'Remove notification',
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Text(notification.caption),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String timeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) return 'Just now';

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }

  final weeks = difference.inDays ~/ 7;
  return '$weeks week${weeks == 1 ? '' : 's'} ago';
}