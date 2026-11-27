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

  // Persist only gathering creation fields; document ID is external.
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'participantIds': participantIds,
    'startDate': formatGatheringDate(startDate),
    'endDate': formatGatheringDate(endDate),
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
  final List<String> participantIds;
  final int _initialPlanningProgress;
  int? _voterCount;

  int get planningProgress => _voterCount == null
      ? _initialPlanningProgress
      : attendingCount == 0 ? 0 : (_voterCount! * 100 / attendingCount).round();

  void setDateVoterCount(int count) {
    _voterCount = count.clamp(0, attendingCount).toInt();
  }
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
    int planningProgress = 0,
    this.participantIds = const [],
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
  }) : _initialPlanningProgress = planningProgress;

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
          (json['dateTime'] != null ? 'confirmed' : 'planning'),
      participantIds: gatheringParticipantIds(json) ?? const [],
      planningProgress: 0,
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
  // UI-only values are deliberately excluded from Firestore.
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'creatorId': creatorId,
    'participantIds': participantIds,
    'startDate': formatGatheringDate(startDate),
    'endDate': formatGatheringDate(endDate),
    'minBudget': minBudget,
    'maxBudget': maxBudget,
    'activities': activities,
    'votingEnded': votingEnded,
    if (dateTime != null) 'dateTime': dateTime!.toUtc().toIso8601String(),
    if (place != null) 'place': place,
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
          '${date.toLocal().day}/${date.toLocal().month}/${date.toLocal().year}',
      dateTime: date,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert a DateOptionModel object into JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
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


// Calendar dates have no time component in Firestore.
String? formatGatheringDate(DateTime? date) {
  if (date == null) return null;
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
