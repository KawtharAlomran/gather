import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';

class PlaceVotingScreen extends StatelessWidget {
  const PlaceVotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Voting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        selectedIndex: 1,
      ),
      body: const Center(
        child: Text(
          'Place Voting Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}