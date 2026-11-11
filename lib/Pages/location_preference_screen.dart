import 'package:flutter/material.dart';
import 'package:gather/Pages/time_preference_screen.dart';
import 'package:gather/Pages/home_page.dart';
import 'package:gather/data/repositories/preference_repository.dart';
import 'package:gather/models/preference_model.dart';
import 'package:gather/shared_widgets/app_button.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_text_field.dart';
import 'package:gather/shared_widgets/invite_method_tabs.dart';
import 'package:gather/shared_widgets/friends_invite_widget.dart';
import 'package:gather/shared_widgets/app_message.dart';
import 'package:gather/shared_widgets/email_invite_widget.dart';
import 'package:gather/shared_widgets/link_invite_widget.dart';


class LocationPreferenceScreen extends StatefulWidget {
  final String selectedTime;
  final List<String> selectedActivities;
  final List<DateTime> selectedDates;

  const LocationPreferenceScreen({
    super.key,
    required this.selectedDates,
    required this.selectedTime,
    required this.selectedActivities,
  });

  @override
  State<LocationPreferenceScreen> createState() =>
      _LocationPreferenceScreenState();
}
class _LocationPreferenceScreenState
    extends State<LocationPreferenceScreen> {
  final PreferenceRepository repository = MockPreferenceRepository();

  final locationController = TextEditingController();
  final suggestedLocationController = TextEditingController();

  Set<String> selectedFriendIds = {};
  List<String> selectedEmails = [];
  InviteMethod selectedMethod = InviteMethod.friends;

  @override
  void dispose() {
    locationController.dispose();
    suggestedLocationController.dispose();
    super.dispose();
  }

  Future<void> savePreferences() async {
    if (locationController.text.trim().isEmpty) {
      AppMessage.show(
        context,
        message: 'Please enter your location',
        type: MessageType.error,
      );
      return;
    }

    final preferences = PreferenceModel(
      dates: widget.selectedDates,
      time: widget.selectedTime,
      activities: widget.selectedActivities,
      location: locationController.text.trim(),
      suggestedLocations:
          suggestedLocationController.text.trim().isEmpty
              ? []
              : [suggestedLocationController.text.trim()],
    );

    await repository.savePreferences(preferences);

    if (!mounted) return;

    AppMessage.show(
      context,
      message: 'Preferences saved successfully!',
      type: MessageType.success,
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TimePreferenceScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: locationController,
                label: 'Select your location',
                hintText: 'Enter city, neighborhood, or venue',
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Suggested locations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: suggestedLocationController,
                label: 'Select location',
                hintText: 'Enter city, neighborhood, or venue',
              ),
            ),

            const SizedBox(height: 24),
            InviteMethodTabs(
              selectedMethod: selectedMethod,
              onChanged: (method) {
                setState(() {
                  selectedMethod = method;
                });
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: _buildInviteContent(),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Save Preferences',
              onPressed: savePreferences,
            ),
          ],
        ),
      ),
      
    );
  }
  Widget _buildInviteContent() {
    switch (selectedMethod) {
      case InviteMethod.friends:
        return FriendsInviteWidget(
          friends: const [
            Invitee(
              id: '1',
              name: 'Sarah',
              email: 'sarah@gmail.com',
            ),
            Invitee(
              id: '2',
              name: 'Manar',
              email: 'manar@gmail.com',
            ),
            Invitee(
              id: '3',
              name: 'Shahad',
              email: 'shahad@gmail.com',
            ),
          ],
          selectedFriendIds: selectedFriendIds,
          onSelectionChanged: (updatedIds) {
            setState(() {
              selectedFriendIds = updatedIds;
            });
          },
        );

      case InviteMethod.email:
        return EmailInviteWidget(
          selectedEmails: selectedEmails,
          onEmailsChanged: (emails) {
            setState(() {
              selectedEmails = emails;
            });
          },
        );

      case InviteMethod.link:
        return const LinkInviteWidget();
    }
  }
}