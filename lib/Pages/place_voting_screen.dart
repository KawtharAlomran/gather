import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gather/Pages/app_bottom_nav.dart';
import 'package:gather/models/place_model.dart';
import 'package:gather/shared_widgets/app_card.dart';

class PlaceVotingScreen extends StatefulWidget {
  const PlaceVotingScreen({super.key});

  @override
  State<PlaceVotingScreen> createState() => _PlaceVotingScreenState();
}

class _PlaceVotingScreenState extends State<PlaceVotingScreen> {
  List<Place> places = [];

  String? votedPlaceId;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

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

  void vote(String placeId) {
    setState(() {
      votedPlaceId = placeId;
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

      bottomNavigationBar: const AppBottomNav(
        selectedIndex: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended for Group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

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

  Widget buildPlaceCard(Place place) {
    final bool isVoted = votedPlaceId == place.id;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Place information
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
                    const Icon(
                      Icons.star_border,
                      size: 18,
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    // If this place has already been voted for,
                    // disable the button
                    onPressed: isVoted
                        ? null
                        : () {
                            vote(place.id);
                          },
                    // Change the text from Vote to Voted
                    child: Text(
                      isVoted ? 'Voted' : 'Vote',
                    ),
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