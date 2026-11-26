import 'package:flutter/material.dart';

import 'Pages/login_screen.dart';
import 'package:gather/Pages/profile_screen.dart';
import 'package:gather/Pages/place_voting_screen.dart';
import 'package:gather/Pages/home_page.dart';
import 'package:gather/Pages/Time_preference_screen.dart';

import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gather App',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        //'/invitations': (context) => const InvitationPage(),
        '/place-voting': (context) => const PlaceVotingScreen(),
        '/home': (context) => const HomePage(),
        //'/update-preferences': (context) => const TimePreferenceScreen(), // Placeholder for the preferences page
      },
    );
  }
}