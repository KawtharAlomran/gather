import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/place_model.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlaces();
  Future<Place?> getPlaceById(String placeId);
}

class MockPlaceRepository implements PlaceRepository {
  List<Place>? _places;

  Future<void> _loadPlaces() async {
    if (_places != null) return;

    final jsonString = await rootBundle.loadString(
      'lib/data/places.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _places = jsonData
        .map(
          (item) => Place.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<List<Place>> getPlaces() async {
    await _loadPlaces();
    return List.unmodifiable(_places!);
  }

  @override
  Future<Place?> getPlaceById(String placeId) async {
    await _loadPlaces();

    for (final place in _places!) {
      if (place.id == placeId) {
        return place;
      }
    }

    return null;
  }
}