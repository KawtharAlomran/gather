import 'package:flutter/material.dart';

import 'Pages/login_screen.dart';

import 'package:gather/Pages/profile_screen.dart';
import 'package:gather/Pages/place_voting_screen.dart';
import 'package:gather/Pages/gathering_details_screen.dart';

import 'package:gather/Pages/InvitationPage.dart';
import 'package:gather/Pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/invitations': (context) => const InvitationPage(),
        '/place-voting': (context) => const PlaceVotingScreen(),
        '/gathering-details': (context) => const GatheringDetailsScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
