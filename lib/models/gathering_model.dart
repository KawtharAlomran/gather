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

  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['id'] as String,
      title: json['title'] as String,
      creatorEmail:
          json['creatorEmail'] as String? ?? json['createdBy'] as String? ?? '',
      participantIds: (json['participantIds'] as List? ?? [])
          .map((id) => id.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'creatorEmail': creatorEmail,
    'participantIds': participantIds,
  };

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

class GatheringModel {
  final String id;
  final String title;
  final String createdBy;
  final String creatorId;
  final int attendingCount;
  final String? place;
  final String status;
  final int planningProgress;
  final List<String> attendeeNames;
  final DateTime? dateTime;
  final List<DateOptionModel> dateOptions;
  String? selectedOptionId;
  bool votingEnded;

  GatheringModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.creatorId,
    this.attendingCount = 0,
    this.place,
    this.status = 'planning',
    this.planningProgress = 0,
    this.attendeeNames = const [],
    this.dateTime,
    this.dateOptions = const [],
    this.selectedOptionId,
    this.votingEnded = false,
  });

  int get totalVotes =>
      dateOptions.fold<int>(0, (total, option) => total + option.votes);

  factory GatheringModel.fromJson(Map<String, dynamic> json) {
    return GatheringModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdBy:
          json['createdBy'] as String? ?? json['creatorEmail'] as String? ?? '',
      creatorId:
          json['creatorId'] as String? ?? json['creatorEmail'] as String? ?? '',
      attendingCount: json['attendingCount'] as int? ?? 0,
      place: json['place'] as String?,
      status:
          json['status'] as String? ??
          (json['dateTime'] != null ? 'confirmed' : 'planning'),
      planningProgress: (json['planningProgress'] as num?)?.toInt() ?? 0,
      attendeeNames: (json['attendeeNames'] as List? ?? [])
          .map((name) => name.toString())
          .toList(),
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      dateOptions: (json['dateOptions'] as List? ?? [])
          .map((item) => DateOptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      selectedOptionId: json['selectedOptionId'] as String?,
      votingEnded: json['votingEnded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdBy': createdBy,
    'creatorId': creatorId,
    'attendingCount': attendingCount,
    'place': place,
    'status': status,
    'planningProgress': planningProgress,
    'attendeeNames': attendeeNames,
    'dateTime': dateTime?.toUtc().toIso8601String(),
    'dateOptions': dateOptions.map((option) => option.toJson()).toList(),
    'selectedOptionId': selectedOptionId,
    'votingEnded': votingEnded,
  };
}

class DateOptionModel {
  final String id;
  final String label;
  final DateTime dateTime;
  int votes;

  DateOptionModel({
    required this.id,
    required this.label,
    required this.dateTime,
    required this.votes,
  });

  factory DateOptionModel.fromJson(Map<String, dynamic> json) {
    return DateOptionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      votes: json['votes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'dateTime': dateTime.toUtc().toIso8601String(),
    'votes': votes,
  };
}
