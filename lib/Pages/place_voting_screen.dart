import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
=======
import 'package:gather/data/repositories/place_repository.dart';
>>>>>>> 06b6ee601f82e6014fd6d05ea1b5303cb69d7e09
import 'package:gather/models/place_model.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_button.dart';

class PlaceVotingScreen extends StatefulWidget {
  const PlaceVotingScreen({super.key});

  @override
  State<PlaceVotingScreen> createState() => _PlaceVotingScreenState();
}

class _PlaceVotingScreenState extends State<PlaceVotingScreen> {
  final PlaceRepository placeRepository = MockPlaceRepository();

  List<Place> places = [];
  String? votedPlaceId;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    try {
      final loadedPlaces = await placeRepository.getPlaces();

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
      votedPlaceId = votedPlaceId == placeId ? null : placeId;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for Group',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: places.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      itemCount: places.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
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
    final bool isVoted = votedPlaceId == place.id;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (place.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                place.image!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.star_border,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  place.category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    text: isVoted ? 'Voted' : 'Vote',
                    fullWidth: false,
                    backgroundColor:
                        isVoted ? colors.primary : colors.secondary,
                    onPressed: () => vote(place.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}