import 'package:flutter/material.dart';
import 'package:gather/data/repositories/place_repository.dart';
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

  List<Place> places = []; // List to hold the loaded places
  String? votedPlaceId; // Store the ID of the place the user has voted for
  
  // Widget to display a placeholder image when the actual image is not available
  Widget _emptyImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: Colors.grey.shade500,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  // Load the places from the repository
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

  // Handle the voting action for a place
  void vote(String placeId) {
    setState(() {
      votedPlaceId = votedPlaceId == placeId ? null : placeId; // Toggle vote for the selected place
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
                  : ListView.separated( // Display the list of places with voting buttons
                      itemCount: places.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) { // Build each place card in the list
                        return buildPlaceCard(places[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the UI for a single place card
  Widget buildPlaceCard(Place place) {
    final bool isVoted = votedPlaceId == place.id;
    final colors = Theme.of(context).colorScheme;
    final imagePath = place.image;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Display the place image or a placeholder if the image is not available
          ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath != null && imagePath.isNotEmpty
              ? Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _emptyImage();
                  },
                )
              : _emptyImage(), // Display placeholder image if the actual image is not available
        ),
        const SizedBox(width: 12),

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
                    // Toggle the vote state for the place when the button is pressed
                    // Update the button text and background color based on the vote state
                    text: isVoted ? 'Voted' : 'Vote',
                    fullWidth: false,
                    backgroundColor:
                        // Change the button color based on whether the user has voted for this place
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