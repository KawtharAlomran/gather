
class Gathering {
  final String id;
  final String title;
  final String creatorEmail;
  final List<String> participantIds;

  const Gathering({
    required this.id,
    required this.title,
    required this.creatorEmail,
    required this.participantIds,
  });

  // Create a Gathering object from JSON.
  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['id'] as String,
      title: json['title'] as String,
      creatorEmail: json['creatorEmail'] as String,
      participantIds: List<String>.from(json['participantIds']),
    );
  }

  // Convert a Gathering object to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creatorEmail': creatorEmail,
      'participantIds': participantIds,
    };
  }

  // Create an updated copy of a Gathering.
  Gathering copyWith({
    String? id,
    String? title,
    String? creatorEmail,
    List<String>? participantIds,
  }) {
    return Gathering(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}

