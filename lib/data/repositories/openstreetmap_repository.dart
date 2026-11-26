import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/place_model.dart';

class OpenStreetMapRepository {
  Future<List<Place>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="restaurant"]
    (around:1000,$latitude,$longitude);

  way["amenity"="restaurant"]
    (around:1000,$latitude,$longitude);
);
out center 5;
''';

    final response = await http
        .post(
          Uri.parse(
            'https://overpass-api.de/api/interpreter',
          ),
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 60));

    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'OpenStreetMap error: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    final elements =
        List<dynamic>.from(json['elements'] ?? []);

    return elements.map<Place>((item) {
      final tags = Map<String, dynamic>.from(
        item['tags'] ?? {},
      );

      final center = item['center'] ?? item;

      return Place(
        placeId: item['id'].toString(),
        name: tags['name'] ?? 'Unnamed restaurant',
        category: tags['amenity'] ?? 'Restaurant',
        address: [
          tags['addr:housenumber'],
          tags['addr:street'],
          tags['addr:city'],
        ].whereType<String>().join(', '),
        cuisine: tags['cuisine'],
        openingHours: tags['opening_hours'],
        phone: tags['phone'],
        website: tags['website'],
        latitude:
            (center['lat'] as num?)?.toDouble() ?? 0.0,
        longitude:
            (center['lon'] as num?)?.toDouble() ?? 0.0,
        outdoorSeating:
            tags['outdoor_seating'] == 'yes',
      );
    }).toList();
  }
}