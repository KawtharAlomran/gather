
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retrieve the current user's notifications in real time.
  Stream<List<NotificationModel>> watchNotifications() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

      notifications.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      return notifications;
    });
  }

  // Mark a notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // Remove a notification from Firebase.
  Future<void> deleteNotification(
    String notificationId,
  ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
