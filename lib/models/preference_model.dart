class PreferenceModel {
  final List<DateTime> dates;
  final Map<DateTime, String> times;
  final List<String> activities;
  final String location;
  final List<String> suggestedLocations;
  final double? latitude;
  final double? longitude;

  const PreferenceModel({
    required this.dates,
    required this.times,
    required this.activities,
    required this.location,
    required this.suggestedLocations,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'dates': dates
          .map((date) => DateTime(date.year, date.month, date.day).toIso8601String())
          .toList(),
      'times': {
        for (final entry in times.entries)
          DateTime(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          ).toIso8601String(): entry.value,
      },
      'activities': activities,
      'location': location,
      'suggestedLocations': suggestedLocations,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PreferenceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dateStrings =
        List<String>.from(json['dates'] ?? []);

    final savedTimes = Map<String, dynamic>.from(
      json['times'] ?? {},
    );

    return PreferenceModel(
      dates: dateStrings.map(DateTime.parse).toList(),
      times: savedTimes.map(
        (date, time) => MapEntry(
          DateTime.parse(date),
          time.toString(),
        ),
      ),
      activities: List<String>.from(
        json['activities'] ?? [],
      ),
      location: json['location'] ?? '',
      suggestedLocations: List<String>.from(
        json['suggestedLocations'] ?? [],
      ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}