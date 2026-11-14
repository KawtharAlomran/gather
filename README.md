# Gather

Gather is a Flutter mobile application that helps users plan group gatherings in an organized and collaborative way.

## Project purpose

Planning a group gathering can be difficult because people may have different schedules, locations, preferences, and budgets. Gather provides a shared application where users can create gatherings, invite others, share their preferences, and participate in group decisions.

## setup/run steps
1. Clone the repository:
git clone https://github.com/KawtharAlomran/gather.git

2. Install the dependencies:
flutter pub get

3. Run the application:
flutter run

4. Use the following test account:
- Email: nour@example.com
- Password: gather123

## Implemented Phase 3 features
- Login and sign up
- Creating new gather
- Collecting members’ locations, preferences and activities
- Displaying the final gathering plan in one organized place
- Profile page
- Adding and deleting friends 
- Accepting/ rejecting invitations 
- Viewing notifications 

## Packages and purpose

The following packages are included in the Flutter project.
 
### Dependencies
 
| Package | Purpose |
|---|---|
| `flutter` | Builds the mobile application and provides UI components. |
| `crypto` | Provides cryptographic hashing functions. |
| `table_calendar` | Provides an interactive calendar for selecting dates. |
| `cupertino_icons` | Provides iOS-style icons. |
| `flutter_map` | Displays interactive maps in Flutter. |
| `latlong2` | Represents geographical coordinates and supports distance calculations. |
| `geocoding` | Converts addresses into coordinates and coordinates into addresses. |
| `geolocator` | Retrieves device location and manages location permissions. |

### Built-in Dart and Flutter Libraries
 
| Library | Purpose |
|---|---|
| `flutter/material.dart` | Provides Material Design widgets and navigation. |
| `flutter/services.dart` | Supports clipboard operations and loading local assets. |
| `dart:convert` | Encodes and decodes JSON data. |
| `dart:async` | Supports asynchronous operations and timers. |
| `dart:math` | Provides random number generation for temporary invitation links. |

## Data source
The application includes main data models:

- `User`: Stores user information such as name, and email.
- `Gathering`: Stores gathering information such as id, title, creator email, and participants.
- `Place`: Stores information about suggested or selected places.
- `Vote`: Stores a user's vote for a specific gathering option.
- `Invitation`: Stores the invitations sends by inviters
- `Notification`: Store the notification related to the gatherings
- `Preference`: Store the user preference for the gathering 
- `Attendee`: Store the users who accepted the gathering

The application currently uses local JSON files as its data source. Repository classes, including UserRepository, InvitationRepository, and GatheringRepository, are used to retrieve and manage application data. This separation allows the data source to be replaced with a backend API in the next phase without major changes to the UI.

## known issues
Currently there is no issues 

## AI-use disclosure
AI tools were used as supplementary support during the development of this project. They assisted with explaining Flutter concepts, suggesting code structure, identifying and resolving minor errors. All generated suggestions were reviewed, adapted, tested, and integrated by the team. The team remains responsible for the final implementation and submitted work.

## Project Structure

```text
gather/
├── .dart_tool/
├── android/
├── assets/
│   └── images/
│       └── background.png
├── build/
├── ios/
├── lib/
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── attendance_repository.dart
│   │   │   ├── gather_repository.dart
│   │   │   ├── gathering_details_repository.dart
│   │   │   ├── invitation_repository.dart
│   │   │   ├── place_repository.dart
│   │   │   ├── preference_repository.dart
│   │   │   └── user_repository.dart
│   │   ├── attendance.json
│   │   ├── gatherings.json
│   │   ├── invitations.json
│   │   ├── notification.json
│   │   ├── places.json
│   │   └── users.json
│   ├── models/
│   │   ├── attendee_model.dart
│   │   ├── gathering_model.dart
│   │   ├── invitation_model.dart
│   │   ├── notification_model.dart
│   │   ├── place_model.dart
│   │   ├── preference_model.dart
│   │   ├── user_model.dart
│   │   └── vote_model.dart
│   ├── Navigation/
│   │   ├── BottomNavigation.dart
│   │   └── gathering_navigation.dart
│   ├── Pages/
│   │   ├── confirmed_gather_page.dart
│   │   ├── create_gathering_screen.dart
│   │   ├── friends_screen.dart
│   │   ├── gathering_details_screen.dart
│   │   ├── home_page.dart
│   │   ├── InvitationPage.dart
│   │   ├── invitee_gather_details_screen.dart
│   │   ├── language_screen.dart
│   │   ├── location_preference_screen.dart
│   │   ├── login_screen.dart
│   │   ├── NotificationPage.dart
│   │   ├── place_voting_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── signup_page.dart
│   │   └── time_preference_screen.dart
│   ├── shared_widgets/
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── app_dialog.dart
│   │   ├── app_message.dart
│   │   ├── app_search_field.dart
│   │   ├── app_text_field.dart
│   │   ├── email_invite_widget.dart
│   │   ├── friends_invite_widget.dart
│   │   ├── gathering_detail_widgets.dart
│   │   ├── gathering_vote_selection.dart
│   │   ├── invite_method_tabs.dart
│   │   └── link_invite_widget.dart
│   ├── states/
│   │   └── notification_read_state.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── main.dart
├── linux/
├── macos/
├── test/
│   └── widget_test.dart
├── web/
├── windows/
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── pubspec.yaml
└── README.md
```

## Technologies
- Flutter
- Dart