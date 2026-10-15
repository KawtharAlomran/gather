import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';
import 'package:gather/Pages/place_voting_screen.dart';

class InviteeGatherDetails extends StatelessWidget {
  const InviteeGatherDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitee Gathering Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Invitee Gathering Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PlaceVotingScreen(),
    ),
  );              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}