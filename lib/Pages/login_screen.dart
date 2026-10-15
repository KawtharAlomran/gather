import 'package:flutter/material.dart';
import 'package:gather/Pages/app_bottom_nav.dart';
import 'package:gather/Pages/invitee_gather_details_screen.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
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
                    builder: (_) =>  HomePage(),
                  ),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpPage(),
                ),
              );
            },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}