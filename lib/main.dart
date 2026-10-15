import 'package:flutter/material.dart';

import 'Pages/login_screen.dart';

import 'package:gather/Pages/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {'/profile': (context) => const ProfileScreen()},
    );
  }
}
