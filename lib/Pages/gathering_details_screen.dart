import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';
import 'package:gather/Pages/TimePreference.dart';
import 'package:gather/Pages/place_voting_screen.dart';


class GatheringDetailsScreen extends StatelessWidget {
  const GatheringDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gathering Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gathering Details Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaceVotingScreen(),
                  ),
                );
              },
              child: const Text('Place Voting'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TimePreferencePage()),
                );
              },
              child: const Text('Set preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
