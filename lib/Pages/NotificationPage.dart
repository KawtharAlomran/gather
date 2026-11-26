
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import '../shared_widgets/app_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {

  final NotificationRepository _repository =
      NotificationRepository();

  late Stream<List<NotificationModel>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _repository.watchNotifications();
  }

  Future<void> _markAsRead(
    NotificationModel notification,
  ) async {
    try {
      await _repository.markAsRead(notification.id);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not mark notification as read: $error',
          ),
        ),
      );
    }
  }

  Future<void> _deleteNotification(
    NotificationModel notification,
  ) async {
    try {
      await _repository.deleteNotification(
        notification.id,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not remove notification: $error',
          ),
        ),
      );
    }
  }

  void _reloadNotifications() {
    setState(() {
      _notifications = _repository.watchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notifications,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(
              'Failed to load notifications: ${snapshot.error}',
            );

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load notifications.',
                  ),
                  TextButton(
                    onPressed: _reloadNotifications,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final notification in notifications)
                AppCard(
                  onTap: () => _markAsRead(notification),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (!notification.isRead) ...[
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 9,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    notification.heading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(timeAgo(notification.date)),
                          IconButton(
                            onPressed: () =>
                                _deleteNotification(
                              notification,
                            ),
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
