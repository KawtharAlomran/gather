import 'package:flutter/material.dart';

import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Current language selected by the user.
  String selectedLanguage = 'English';
  // Used to determine whether the user changed the language.
  String initialLanguage = 'English';

  void _saveLanguage() {
    // Do not save if the language was not changed.
    if (selectedLanguage == initialLanguage) {
      return;
    }
    AppMessage.show(
      context,
      message: 'Language saved successfully!',
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'English',
                    groupValue: selectedLanguage,
                    // Update the selected language and refresh the UI.
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Arabic'),
                    value: 'Arabic',
                    groupValue: selectedLanguage,
                    // Update the selected language and refresh the UI.
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Enable Save only after the user selects a different language.
            AppButton(
              text: 'Save',
              onPressed: selectedLanguage == initialLanguage
              ? null
              : _saveLanguage,
            ),
          ],
        ),
      ),
    );
  }
}