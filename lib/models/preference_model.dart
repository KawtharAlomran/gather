class PreferenceModel {
  final List<DateTime> dates;
  final String time;
  final List<String> activities;
  final String location;
  final List<String> suggestedLocations;

  const PreferenceModel({
    required this.dates,
    required this.time,
    required this.activities,
    required this.location,
    required this.suggestedLocations,
  });
}
