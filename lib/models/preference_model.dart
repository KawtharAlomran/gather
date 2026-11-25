class PreferenceModel {
  final List<DateTime> dates;
  final Map<DateTime, String> times;
  final List<String> activities;
  final String location;
  final List<String> suggestedLocations;

  const PreferenceModel({
    required this.dates,
    required this.times,
    required this.activities,
    required this.location,
    required this.suggestedLocations,
  });

  // Convert the model into fields that Firestore can save.
  Map<String, dynamic> toJson() {
    return {
      'dates': dates.map((date) => date.toIso8601String()).toList(),
      'times': times.map(
        (date, time) => MapEntry(date.toIso8601String(), time),
      ),
      'activities': activities,
      'location': location,
      'suggestedLocations': suggestedLocations,
    };
  }

  // Build the model from fields read from Firestore.
  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    final dateStrings = List<String>.from(json['dates'] as List);
    final savedTimes = Map<String, String>.from(json['times'] as Map);

    return PreferenceModel(
      dates: dateStrings.map(DateTime.parse).toList(),
      times: savedTimes.map(
        (date, time) => MapEntry(DateTime.parse(date), time),
      ),
      activities: List<String>.from(json['activities'] as List),
      location: json['location'] as String,
      suggestedLocations: List<String>.from(
        json['suggestedLocations'] as List,
      ),
    );
  }
}