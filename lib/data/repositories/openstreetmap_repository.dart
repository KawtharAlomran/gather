import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/place_model.dart';
import 'package:flutter/foundation.dart';


class OpenStreetMapRepository {
  Future<List<Place>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
  }) async {
    final query = '''
[out:json];
(
  node["amenity"="restaurant"](around:1000,$latitude,$longitude);
  way["amenity"="restaurant"](around:1000,$latitude,$longitude);
);
out 5;
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
    final elements = json['elements'] as List;

    return elements.map<Place>((item) {
      final tags =
          Map<String, dynamic>.from(item['tags'] ?? {});

      return Place(
        placeId: item['id'].toString(),
        name: tags['name'] ?? 'Unnamed restaurant',
        category: 'Restaurant',
        rating: 0.0,
        reviewCount: 0,
        address: [
            tags['addr:street'],
            tags['addr:housenumber'],
            tags['addr:city'],
          ].whereType<String>().join(', '),
        image: null,
        googleMapsUrl: null,
      );
    }).toList();
  }
}