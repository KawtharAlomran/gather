import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Frontend-only notification read state. No backend or persistent storage.
class NotificationReadState {
  NotificationReadState._();

  static final ValueNotifier<Set<String>> unreadKeys =
      ValueNotifier<Set<String>>(<String>{});

  static bool _loaded = false;

  static String keyFor(String heading, DateTime date) =>
      '$heading|${date.toUtc().toIso8601String()}';

  static Future<void> load() async {
    if (_loaded) return;
    final source = await rootBundle.loadString('lib/data/notification.json');
    final items = jsonDecode(source) as List;
    unreadKeys.value = {
      for (final raw in items)
        if ((raw as Map<String, dynamic>)['isRead'] == false)
          keyFor(
            raw['heading'] as String,
            DateTime.parse(raw['date'] as String),
          ),
    };
    _loaded = true;
  }

  static bool isUnread(String heading, DateTime date) =>
      unreadKeys.value.contains(keyFor(heading, date));

  static void markRead(String heading, DateTime date) {
    final key = keyFor(heading, date);
    if (!unreadKeys.value.contains(key)) return;
    unreadKeys.value = {...unreadKeys.value}..remove(key);
  }
}
