class NotificationModel {
  final String id;
  final String receiverId;
  final String heading;
  final String caption;
  final DateTime date;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.receiverId,
    required this.heading,
    required this.caption,
    required this.date,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return NotificationModel(
      id: documentId,
      receiverId: data['receiverId'] as String? ?? '',
      heading: data['heading'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      date: DateTime.parse(data['date'] as String),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'heading': heading,
      'caption': caption,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }
}