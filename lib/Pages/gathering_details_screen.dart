import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';

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
      bottomNavigationBar: const AppBottomNav(
        selectedIndex: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gathering Details Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/place-voting');
              },
              child: const Text('Place Voting'),
            ),
          ],
        ),
      ),
    );
  }
}