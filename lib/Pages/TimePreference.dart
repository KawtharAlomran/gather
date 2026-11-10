import 'package:flutter/material.dart';
import 'package:gather/Pages/LocationPreferencePage.dart';
import 'package:gather/Pages/gathering_details_screen.dart';
import 'package:gather/shared_widgets/app_button.dart';
import 'package:gather/shared_widgets/app_text_field.dart';
import 'package:gather/shared_widgets/app_search_field.dart';

class TimePreferencePage extends StatelessWidget {
  const TimePreferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Preference'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GatheringDetailsScreen(),
                  ),
                );
              },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Time Preference',
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
                    builder: (_) => const LocationPreferencePage(),
                  ),
                );
              },
              child: const Text('Next'),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                SizedBox(
                  width: 150,
                  child: AppTextField(
                    label: 'Preferred Time',
                    hintText: 'Enter your preferred time',
                  ),
                ),

                SizedBox(
                  width: 150,
                  child: AppSearchField(
                    hintText: 'Enter an alternate time',
                  ),
                ),

                SizedBox(
                  width: 400,
                  height: 50,
                  child: AppButton(
                    text: 'Submit',
                    backgroundColor: const Color.fromARGB(255, 80, 101, 117),
                    onPressed: () {
                      // Handle submit action
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}