import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';
import 'package:gather/Pages/TimePreference.dart';

class CreateGathering extends StatelessWidget {
  const CreateGathering({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      appBar: AppBar(
        title: const Text('Create Gathering'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)
,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create Gathering Page',
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
      builder: (context) => TimePreferencePage(),
    ),
  );
},
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}