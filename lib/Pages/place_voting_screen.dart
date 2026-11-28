import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gather/models/place_model.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_button.dart';

import '../data/repositories/openstreetmap_repository.dart';
import '../data/repositories/vote_repository.dart';
import '../data/repositories/preference_repository.dart';
import '../data/services/location_service.dart';
import '../data/repositories/place_repository.dart';

class PlaceVotingScreen extends StatefulWidget {
  final String gatheringId;

  const PlaceVotingScreen({super.key, required this.gatheringId});

  @override
  State<PlaceVotingScreen> createState() => _PlaceVotingScreenState();
}

class _PlaceVotingScreenState extends State<PlaceVotingScreen> {
  bool isLoading = true;
  String? errorMessage;

  final FirebasePlaceRepository placeRepository = FirebasePlaceRepository();

  final OpenStreetMapRepository searchRepository = OpenStreetMapRepository();

  final VoteRepository voteRepository = VoteRepository();

  final PreferenceRepository preferenceRepository =
      FirebasePreferenceRepository();

  final LocationService locationService = LocationService();

  List<Place> places = [];
  String? votedPlaceId;
  bool _savingPlaceVote = false;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  String get gatheringId => widget.gatheringId;

  @override
  void initState() {
    super.initState();
    loadPlaces();
    loadUserVote();
  }

  Future<void> loadPlaces() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final access = await FirebaseFirestore.instance
          .collection('gatherings')
          .doc(gatheringId)
          .get();
      final accessData = access.data();
      if (accessData == null) throw StateError('Gathering not found.');
      if (!(List<String>.from(accessData['participantIds'] ?? []))
          .contains(userId)) {
        throw StateError('You are no longer participating in this gathering.');
      }
      if (accessData['votingEnded'] != true) {
        throw StateError('Place voting starts after date voting ends.');
      }
      // First, load places already saved for this gathering.
      var loadedPlaces = await placeRepository.getPlacesForGathering(
        gatheringId,
      );

      final hasAppPlaces = loadedPlaces.any((place) => place.source == 'app');

      if (!hasAppPlaces) {
        final document = await FirebaseFirestore.instance
            .collection('gatherings')
            .doc(gatheringId)
            .get();

        final data = document.data();

        if (data == null) {
          throw Exception('Gathering not found.');
        }

        final participantIds = List<String>.from(data['participantIds'] ?? []);

        // Load user-suggested places.
        final userSuggestedPlaces = await _loadUserSuggestedPlaces(
          participantIds,
        );

        // Find the group center.
        final locations = await preferenceRepository.getParticipantLocations(
          participantIds, gatheringId: gatheringId,
        );

        if (locations.isEmpty) {
          throw Exception('No participant locations are available.');
        }

        final center = locationService.calculateGroupCenter(locations);

        // Search places recommended by the app.
        List<Place> appPlaces = [];
        try {
          appPlaces = await searchRepository.searchNearbyPlaces(
            latitude: center['latitude']!,
            longitude: center['longitude']!,
          );
        } catch (error) {
          debugPrint('First map server failed: $error');

          try {
            appPlaces = await searchRepository.searchNearbyPlacesFromBackup(
              latitude: center['latitude']!,
              longitude: center['longitude']!,
            );
          } catch (backupError) {
            throw Exception(
              'Could not find nearby places from participant locations.',
            );
          }
        }

        // Keep user suggestions and add app recommendations.
        loadedPlaces = [...loadedPlaces, ...userSuggestedPlaces, ...appPlaces];

        await placeRepository.savePlacesForGathering(gatheringId, loadedPlaces);
      }

      if (!mounted) return;

      setState(() {
        places = loadedPlaces;
        isLoading = false;

        if (places.isEmpty) {
          errorMessage = 'No places found.';
        }
      });
    } catch (error) {
      debugPrint('Error loading places: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<List<Place>> _loadUserSuggestedPlaces(
    List<String> participantIds,
  ) async {
    final suggestions = <Place>[];

    for (final userId in participantIds) {
      final document = await FirebaseFirestore.instance
          .collection('gatherings').doc(gatheringId)
          .collection('preferences')
          .doc(userId)
          .get();

      final data = document.data();

      if (data == null) continue;

      final locations = List<String>.from(data['suggestedLocations'] ?? []);

      for (var index = 0; index < locations.length; index++) {
        final parts = locations[index].split(',');

        if (parts.length != 2) continue;

        final latitude = double.tryParse(parts[0].trim());
        final longitude = double.tryParse(parts[1].trim());

        if (latitude == null || longitude == null) continue;

        suggestions.add(
          Place(
            placeId: 'user_${userId}_$index',
            name: 'User suggested place',
            category: 'Suggested place',
            address: locations[index],
            latitude: latitude,
            longitude: longitude,
            source: 'user',
          ),
        );
      }
    }

    return suggestions;
  }

  Future<void> vote(String placeId) async {
    if (_savingPlaceVote) return;
    final currentUserId = userId;

    if (currentUserId == null) {
      debugPrint('User is not logged in');
      return;
    }

    final previousVoteId = votedPlaceId;
    final isRemovingVote = votedPlaceId == placeId;

    setState(() {
      _savingPlaceVote = true;
      votedPlaceId = isRemovingVote ? null : placeId;
    });

    try {
      if (isRemovingVote) {
        await voteRepository.deleteVote(
          gatheringId: gatheringId,
          userId: currentUserId,
          targetType: 'place',
        );
      } else {
        await voteRepository.saveVote(
          gatheringId: gatheringId,
          userId: currentUserId,
          targetId: placeId,
          targetType: 'place',
        );
      }
    } catch (e) {
      debugPrint('Error saving vote: $e');
      if (!mounted) return;
      setState(() => votedPlaceId = previousVoteId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _savingPlaceVote = false);
    }
  }

  Future<void> loadUserVote() async {
    if (_savingPlaceVote) return;
    final currentUserId = userId;

    if (currentUserId == null) return;

    final votes = await voteRepository.getVotes(
      gatheringId,
      targetType: 'place',
    );

    final userVote = votes.where((vote) => vote.userId == currentUserId);

    if (userVote.isNotEmpty && mounted) {
      setState(() {
        votedPlaceId = userVote.first.targetId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Place Voting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for Group',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Text(errorMessage!, textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      itemCount: places.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return buildPlaceCard(places[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceCard(Place place) {
    final isVoted = votedPlaceId == place.placeId;

    final colors = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(Icons.restaurant, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: place.source == 'user'
                  ? Colors.orange.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              place.source == 'user'
                  ? 'Suggested by a user'
                  : 'Recommended by the app',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: place.source == 'user'
                    ? Colors.orange.shade900
                    : Colors.blue.shade900,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _infoRow(Icons.category_outlined, place.category),

          _infoRow(
            Icons.location_on_outlined,
            place.address.isNotEmpty ? place.address : 'Address unavailable',
          ),

          _infoRow(
            Icons.map_outlined,
            '${place.latitude.toStringAsFixed(5)}, '
            '${place.longitude.toStringAsFixed(5)}',
          ),

          if (place.cuisine != null && place.cuisine!.isNotEmpty)
            _infoRow(Icons.restaurant_menu, place.cuisine!),

          if (place.openingHours != null && place.openingHours!.isNotEmpty)
            _infoRow(Icons.access_time, place.openingHours!),

          if (place.phone != null && place.phone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, place.phone!),

          if (place.website != null && place.website!.isNotEmpty)
            _infoRow(Icons.language, place.website!),

          if (place.outdoorSeating)
            _infoRow(Icons.deck_outlined, 'Outdoor seating available'),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: isVoted ? 'Voted' : 'Vote',
              fullWidth: false,
              backgroundColor: isVoted ? colors.primary : colors.secondary,
              onPressed: _savingPlaceVote ? null : () => vote(place.placeId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}