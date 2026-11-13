import 'package:flutter/material.dart';

import 'signup_page.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_text_field.dart';
import '../Navigation/BottomNavigation.dart';
import '../data/repositories/user_repository.dart';
import '../shared_widgets/app_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Identifies and validates the login form.
  final _formKey = GlobalKey<FormState>();

  // Store the values entered in the email and password fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Provides local user data for authentication.
  final UserRepository _userRepository = MockUserRepository();

  // To show a loading state while login is being processed.
  bool isLoading = false;

  // Release the text controllers when the screen is removed.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate the form, authenticate the user, and navigate on success.
  Future<void> _login() async {
    // Stop the login process if the input is invalid.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Show the loading indicator while authentication is in progress.
    setState(() {
      isLoading = true;
    });

    // Check the entered credentials against the local user data.
    final user = await _userRepository.login(
      _emailController.text,
      _passwordController.text,
    );

    // Make sure the screen still exists before updating its state.
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // Display an error if the credentials are incorrect.
    if (user == null) {
      AppMessage.show(
        context,
        message: 'Invalid email or password.',
        type: MessageType.error,
      );
      return;
    }
    // Open the main app navigation after a successful login.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),

                Text(
                  'Welcome Back to',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                Text(
                  'Gather!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),

                const SizedBox(height: 48),

                AppTextField(
                  label: 'Email',
                  hintText: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'Log in',
                  onPressed: _login,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Open the registration screen for new users.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}