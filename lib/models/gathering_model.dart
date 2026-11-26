import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class Gathering {
  final String id;
  final String title;
  final String creatorEmail;
  final List<String> participantIds;

  // Gathering creation details
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minBudget;
  final double? maxBudget;
  final List<String> activities;

  const Gathering({
    required this.id,
    required this.title,
    required this.creatorEmail,
    required this.participantIds,
    this.startDate,
    this.endDate,
    this.minBudget,
    this.maxBudget,
    this.activities = const [],
  });

  // Create a Gathering object from JSON.
  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['id'] as String,
      title: json['title'] as String,
      creatorEmail:
          json['creatorEmail'] as String? ??
          json['createdBy'] as String? ??
          '',
      participantIds: (json['participantIds'] as List? ?? [])
          .map((id) => id.toString())
          .toList(),

      // New creation fields
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      minBudget: (json['minBudget'] as num?)?.toDouble(),
      maxBudget: (json['maxBudget'] as num?)?.toDouble(),
      activities: (json['activities'] as List? ?? [])
          .map((activity) => activity.toString())
          .toList(),
    );
  }

  // Convert a Gathering object into JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'creatorEmail': creatorEmail,
    'participantIds': participantIds,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'minBudget': minBudget,
    'maxBudget': maxBudget,
    'activities': activities,
  };

  // Create an updated copy without modifying the original.
  Gathering copyWith({
    String? id,
    String? title,
    String? creatorEmail,
    List<String>? participantIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minBudget,
    double? maxBudget,
    List<String>? activities,
  }) {
    return Gathering(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      participantIds: participantIds ?? this.participantIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      activities: activities ?? this.activities,
    );
  }
}

// GatheringModel - Gathering details and voting

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

  // New gathering creation details
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minBudget;
  final double? maxBudget;
  final List<String> activities;

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

    // Optional creation fields
    this.startDate,
    this.endDate,
    this.minBudget,
    this.maxBudget,
    this.activities = const [],
  });

  // Calculate total votes across all date options.
  int get totalVotes =>
      dateOptions.fold<int>(
        0,
        (total, option) => total + option.votes,
      );

  // Create a GatheringModel object from JSON.
  factory GatheringModel.fromJson(Map<String, dynamic> json) {
    return GatheringModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdBy:
          json['createdBy'] as String? ??
          json['creatorEmail'] as String? ??
          '',
      creatorId:
          json['creatorId'] as String? ??
          json['creatorEmail'] as String? ??
          '',
      attendingCount: gatheringParticipantIds(json)?.length
          ?? (json['attendingCount'] as int?)
          ?? (json['attendeeNames'] as List?)?.length
          ?? 0,
      place: json['place'] as String?,
      status:
          json['status'] as String? ??
          (json['dateTime'] != null ? 'confirmed' : 'planning'),
      planningProgress:
          (json['planningProgress'] as num?)?.toInt() ?? 0,
      attendeeNames: (json['attendeeNames'] as List? ?? [])
          .map((name) => name.toString())
          .toList(),
      dateTime: parseDate(json['dateTime']),
      dateOptions: (json['dateOptions'] as List? ?? [])
          .map(
            (item) => DateOptionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      selectedOptionId: json['selectedOptionId'] as String?,
      votingEnded: json['votingEnded'] as bool? ?? false,

      // New creation fields
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      minBudget: (json['minBudget'] as num?)?.toDouble(),
      maxBudget: (json['maxBudget'] as num?)?.toDouble(),
      activities: (json['activities'] as List? ?? [])
          .map((activity) => activity.toString())
          .toList(),
    );
  }

  // Convert a GatheringModel object into JSON.
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
    'dateOptions': dateOptions
        .map((option) => option.toJson())
        .toList(),
    'selectedOptionId': selectedOptionId,
    'votingEnded': votingEnded,

    // New creation fields
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'minBudget': minBudget,
    'maxBudget': maxBudget,
    'activities': activities,
  };
}

// DateOptionModel - Date voting options

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

  // Create a DateOptionModel object from JSON.
  factory DateOptionModel.fromJson(Map<String, dynamic> json) {
    final date = parseDate(json['dateTime'])!;
    return DateOptionModel(
      id: json['id'] as String,
      label: json['label'] as String? ??
          '${date.day}/${date.month}/${date.year}',
      dateTime: date,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert a DateOptionModel object into JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'dateTime': dateTime.toUtc().toIso8601String(),
  };
}

// Null means a legacy record with no membership array; [] means nobody is attending.
List<String>? gatheringParticipantIds(Map<String, dynamic> data) {
  final ids = data['participantIds'];
  if (ids == null) return null;
  return (ids as List)
      .whereType<String>()
      .where((uid) => uid.trim().isNotEmpty)
      .toSet()
      .toList();
}

