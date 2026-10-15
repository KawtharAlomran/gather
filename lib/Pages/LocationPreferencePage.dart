import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';
import 'package:gather/Pages/home_page.dart';
import 'package:gather/Pages/TimePreference.dart';

class LocationPreferencePage extends StatelessWidget {
  const LocationPreferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Preference'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TimePreferencePage()
                  ),
                );
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
              'Location Preference',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}