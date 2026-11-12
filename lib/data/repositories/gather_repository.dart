import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/gathering_model.dart';

// Defines the operations for managing gatherings.
abstract class GatheringRepository {
  Future<List<Gathering>> getGatherings();

  Future<Gathering?> getGatheringById(String gatheringId);

  Future<Gathering> createGathering(Gathering gathering);

  Future<Gathering> updateGathering(Gathering gathering);

  Future<void> deleteGathering(String gatheringId);
}

// Temporary repository using local JSON data.
class MockGatheringRepository implements GatheringRepository {
  List<Gathering>? _gatherings;

  // Load gatherings from JSON only once per repository instance.
  Future<void> _loadGatherings() async {
    if (_gatherings != null) return;

    final jsonString = await rootBundle.loadString('lib/data/gatherings.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _gatherings = jsonData
        .map((item) => Gathering.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get all gatherings.
  @override
  Future<List<Gathering>> getGatherings() async {
    await _loadGatherings();
    return List.unmodifiable(_gatherings!);
  }

  // Find a gathering by its ID.
  @override
  Future<Gathering?> getGatheringById(String gatheringId) async {
    await _loadGatherings();

    for (final gathering in _gatherings!) {
      if (gathering.id == gatheringId) {
        return gathering;
      }
    }

    return null;
  }

  // Create a new gathering.
  @override
  Future<Gathering> createGathering(Gathering gathering) async {
    await _loadGatherings();

    final exists = _gatherings!.any((item) => item.id == gathering.id);

    if (exists) {
      throw StateError('Gathering already exists: ${gathering.id}');
    }

    _gatherings!.add(gathering);
    return gathering;
  }

  // Update an existing gathering.
  @override
  Future<Gathering> updateGathering(Gathering gathering) async {
    await _loadGatherings();

    final index = _gatherings!.indexWhere((item) => item.id == gathering.id);

    if (index == -1) {
      throw StateError('Gathering not found: ${gathering.id}');
    }

    _gatherings![index] = gathering;
    return gathering;
  }

  // Delete a gathering by its ID.
  @override
  Future<void> deleteGathering(String gatheringId) async {
    await _loadGatherings();

    final index = _gatherings!.indexWhere((item) => item.id == gatheringId);

    if (index == -1) {
      throw StateError('Gathering not found: $gatheringId');
    }

    _gatherings!.removeAt(index);
  }
}

// Example usage:
//
// final repository = MockGatheringRepository();
//
// final gatherings = await repository.getGatherings();
//
// final gathering = await repository.getGatheringById('gather_1');
//
// final newGathering = Gathering(
//   id: 'gather_3',
//   title: 'Weekend Picnic',
//   creatorEmail: 'nour@example.com',
//   participantIds: ['user_1', 'user_2'],
// );
//
// await repository.createGathering(newGathering);
//
// Notes:
// - Gathering data is loaded from lib/data/gatherings.json.
// - JSON data is loaded once per repository instance.
// - Create, update, and delete operations modify in-memory data.
// - Changes are not persisted after the repository is recreated.
// - The repository can later integrate API and local caching.
// - Compatible with BLoC, Cubit, and Provider.
