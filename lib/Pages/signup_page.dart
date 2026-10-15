import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          child: const Text('Sign Up'),
        ),
      ),
    );
  }
}