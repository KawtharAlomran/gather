import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/place_model.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlaces();
  Future<Place?> getPlaceById(String placeId);
}

class FirebasePlaceRepository implements PlaceRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  Future<List<Place>> getPlaces() async {
    final snapshot =
        await _firestore.collection('places').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Place.fromJson({
        'id': data['id'] ?? doc.id,
        'name': data['name'] ?? '',
        'category': data['category'] ?? '',
        'rating': data['rating'] ?? 0.0,
        'reviewCount': data['reviewCount'] ?? 0,
        'image': data['image'],
        'address': data['address'] ?? '',
        'googleMapsUrl': data['googleMapsUrl'],
      });
    }).toList();
  }

  @override
  Future<Place?> getPlaceById(String placeId) async {
    final doc = await _firestore
        .collection('places')
        .doc(placeId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;

    return Place.fromJson({
      'id': data['id'] ?? doc.id,
      'name': data['name'] ?? '',
      'category': data['category'] ?? '',
      'rating': data['rating'] ?? 0.0,
      'image': data['image'],
    });
  }

}