# Gather

Gather is a Flutter mobile application that helps users plan group gatherings in an organized and collaborative way.

## Project Description

Planning a group gathering can be difficult because people may have different schedules, locations, preferences, and budgets. Gather provides a shared application where users can create gatherings, invite others, share their preferences, and participate in group decisions.

## Application Pages

- Login page
- Sign up page
- Home page
- Invitations page
- Notifications page
- Profile page
- Create gathering page
- Gathering details page
- Location preferences page
- Time preferences page
- Place voting page
- Invitee gathering details page

## Data Model and Data Source

The application includes four main data models:

- `User`: Stores user information such as name, and email.
- `Gathering`: Stores gathering information such as id, title, creator email, and participants.
- `Place`: Stores information about suggested or selected places.
- `Vote`: Stores a user's vote for a specific gathering option.

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── gathering_model.dart
│   ├── place_model.dart
│   ├── user_model.dart
│   └── vote_model.dart
└── Pages/
    ├── app_bottom_nav.dart
    ├── create_gathering_screen.dart
    ├── friends_screen.dart
    ├── gathering_details_screen.dart
    ├── home_page.dart
    ├── InvitationPage.dart
    ├── invitee_gather_details_screen.dart
    ├── language_screen.dart
    ├── LocationPreferencePage.dart
    ├── login_screen.dart
    ├── NotificationPage.dart
    ├── place_voting_screen.dart
    ├── profile_screen.dart
    ├── signup_page.dart
    └── TimePreference.dart

pubspec.yaml
README.md
```

## Technologies
- Flutter
- Dart

## How to Run the Project
1. Clone the repository:
git clone https://github.com/KawtharAlomran/gather.git

2. Install the dependencies:
flutter pub get

3. Run the application:
flutter run