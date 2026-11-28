import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/place_model.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlaces();

  Future<Place?> getPlaceById(String placeId);

  Future<List<Place>> getPlacesForGathering(
    String gatheringId,
  );

  Future<void> savePlacesForGathering(
    String gatheringId,
    List<Place> places,
  );
}

class FirebasePlaceRepository implements PlaceRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get places from the global places collection.
  @override
  Future<List<Place>> getPlaces() async {
    final snapshot =
        await _firestore.collection('places').get();

    return snapshot.docs
        .map((doc) => _placeFromData(doc.data(), doc.id))
        .toList();
  }

  // Get one place from the global places collection.
  @override
  Future<Place?> getPlaceById(String placeId) async {
    final doc = await _firestore
        .collection('places')
        .doc(placeId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _placeFromData(doc.data()!, doc.id);
  }

  // Get places saved for one gathering.
  @override
  Future<List<Place>> getPlacesForGathering(
    String gatheringId,
  ) async {
    final snapshot = await _firestore
        .collection('gatherings')
        .doc(gatheringId)
        .collection('places')
        .get();

    return snapshot.docs
        .map((doc) => _placeFromData(doc.data(), doc.id))
        .toList();
  }

  // Save the same places for all participants of one gathering.
  @override
  Future<void> savePlacesForGathering(
    String gatheringId,
    List<Place> places,
  ) async {
    final batch = _firestore.batch();

    final placesReference = _firestore
        .collection('gatherings')
        .doc(gatheringId)
        .collection('places');

    for (final place in places) {
      final placeId = place.placeId.isEmpty
          ? '${place.latitude}_${place.longitude}'
          : place.placeId;

      final documentReference =
          placesReference.doc(placeId);

      batch.set(documentReference, {
        'placeId': placeId,
        'name': place.name,
        'category': place.category,
        'address': place.address,
        'cuisine': place.cuisine,
        'openingHours': place.openingHours,
        'phone': place.phone,
        'website': place.website,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'outdoorSeating': place.outdoorSeating,
      });
    }

    await batch.commit();
  }

  Place _placeFromData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Place.fromJson({
      'placeId': data['placeId'] ??
          data['id'] ??
          documentId,
      'name': data['name'] ??
          'Unnamed restaurant',
      'category': data['category'] ??
          'Restaurant',
      'address': data['address'] ??
          'Address unavailable',
      'cuisine': data['cuisine'],
      'openingHours': data['openingHours'],
      'phone': data['phone'],
      'website': data['website'],
      'latitude': (data['latitude'] as num?)
              ?.toDouble() ??
          0.0,
      'longitude': (data['longitude'] as num?)
              ?.toDouble() ??
          0.0,
      'outdoorSeating':
          data['outdoorSeating'] == true,
    });
  }
}