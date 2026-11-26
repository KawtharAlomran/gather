import 'package:flutter/material.dart';
import 'package:gather/models/place_model.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_button.dart';
import '../data/repositories/openstreetmap_repository.dart';

class PlaceVotingScreen extends StatefulWidget {
  const PlaceVotingScreen({super.key});

  @override
  State<PlaceVotingScreen> createState() =>
      _PlaceVotingScreenState();
}

class _PlaceVotingScreenState
    extends State<PlaceVotingScreen> {
  final OpenStreetMapRepository placeRepository =
      OpenStreetMapRepository();

  final double userLatitude = 26.2235;
  final double userLongitude = 50.5876;

  List<Place> places = [];
  String? votedPlaceId;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    try {
      final loadedPlaces =
          await placeRepository.searchNearbyPlaces(
        latitude: userLatitude,
        longitude: userLongitude,
      );

      if (!mounted) return;

      setState(() {
        places = loadedPlaces;
      });
    } catch (e) {
      debugPrint('Error loading places: $e');
    }
  }

  void vote(String placeId) {
    setState(() {
      votedPlaceId =
          votedPlaceId == placeId ? null : placeId;
    });
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for Group',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: places.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      itemCount: places.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return buildPlaceCard(
                          places[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceCard(Place place) {
    final isVoted =
        votedPlaceId == place.placeId;

    final colors =
        Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    colors.primaryContainer,
                child: Icon(
                  Icons.restaurant,
                  color: colors.primary,
                ),
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

          const SizedBox(height: 12),

          if (place.cuisine != null &&
              place.cuisine!.isNotEmpty)
            _infoRow(
              Icons.restaurant_menu,
              place.cuisine!,
            ),

          if (place.address.isNotEmpty)
            _infoRow(
              Icons.location_on_outlined,
              place.address,
            ),

          if (place.openingHours != null &&
              place.openingHours!.isNotEmpty)
            _infoRow(
              Icons.access_time,
              place.openingHours!,
            ),

          if (place.phone != null &&
              place.phone!.isNotEmpty)
            _infoRow(
              Icons.phone_outlined,
              place.phone!,
            ),

          if (place.outdoorSeating)
            _infoRow(
              Icons.deck_outlined,
              'Outdoor seating available',
            ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: isVoted ? 'Voted' : 'Vote',
              fullWidth: false,
              backgroundColor: isVoted
                  ? colors.primary
                  : colors.secondary,
              onPressed: () => vote(place.placeId),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}