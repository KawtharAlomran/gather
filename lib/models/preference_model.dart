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
}
