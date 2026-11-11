class NotificationModel {
  final String heading;
  final String caption;
  final DateTime date;

  const NotificationModel({
    required this.heading,
    required this.caption,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      heading: json['heading'] as String,
      caption: json['caption'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}