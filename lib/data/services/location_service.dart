import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool enabled =
        await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    return Geolocator.getCurrentPosition();
  }

  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Map<String, double> calculateGroupCenter(
    List<Map<String, double>> locations,
  ) {
    if (locations.isEmpty) {
      throw Exception('No locations available.');
    }

    final averageLatitude = locations
            .map((location) => location['latitude']!)
            .reduce((a, b) => a + b) /
        locations.length;

    final averageLongitude = locations
            .map((location) => location['longitude']!)
            .reduce((a, b) => a + b) /
        locations.length;

    return {
      'latitude': averageLatitude,
      'longitude': averageLongitude,
    };
  }
}