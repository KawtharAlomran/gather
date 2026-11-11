import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gather/models/place_model.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_button.dart';

class PlaceVotingScreen extends StatefulWidget {
  const PlaceVotingScreen({super.key});

  @override
  State<PlaceVotingScreen> createState() => _PlaceVotingScreenState();
}

class _PlaceVotingScreenState extends State<PlaceVotingScreen> {
  // Places loaded from the JSON file
  List<Place> places = [];

  // Stores the ID of the place that the user voted for
  String? votedPlaceId;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  // Load places from the local JSON file
  Future<void> loadPlaces() async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/data/places.json');

      final List<dynamic> jsonData = jsonDecode(jsonString);

      setState(() {
        places = jsonData
            .map((json) => Place.fromJson(json))
            .toList();
      });

      debugPrint('Places loaded: ${places.length}');
    } catch (e) {
      debugPrint('Error loading places: $e');
    }
  }

  // Vote or remove vote
  void vote(String placeId) {
    setState(() {
      if (votedPlaceId == placeId) {
        // Clicking Voted again removes the vote
        votedPlaceId = null;
      } else {
        // Vote for this place
        votedPlaceId = placeId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Place Voting',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
            // Filter chips
            const Row(
              children: [
                Chip(
                  label: Text('Italian'),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('Distance < 2mi'),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('Highly Rated'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section title
            Text(
              'Recommended for Group',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 16),

            // List of places
            Expanded(
              child: places.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      itemCount: places.length,

                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },

                      itemBuilder: (context, index) {
                        final place = places[index];

                        return buildPlaceCard(place);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds one place card
  Widget buildPlaceCard(Place place) {
    // True only for the place that the user voted for
    final bool isVoted = votedPlaceId == place.id;

    // Get colors from AppTheme through ThemeData
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Place information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place name
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Place rating
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

                // Place category
                Text(
                  place.category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 10),

                // Vote button
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    text: isVoted ? 'Voted' : 'Vote',

                    fullWidth: false,
                    backgroundColor: isVoted
                        ? colors.primary
                        : colors.secondary,
                    onPressed: () {
                      vote(place.id);
                    },
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