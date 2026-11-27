import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/user_repository.dart';
import '../shared_widgets/app_message.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Identifies and validates the sign up form.
  final _formKey = GlobalKey<FormState>();

  // Store the values entered in the sign up fields.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Release all text controllers when the screen is removed.
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  final UserRepository _userRepository = FirebaseUserRepository();
  bool isLoading = false;
  
  // Validate the form and return to Login after successful validation.
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _userRepository.signUp(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      AppMessage.show(
        context,
        message: 'Account created successfully.',
        type: MessageType.success,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      if (error.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (error.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email.';
      } else {
        message = 'Could not create the account.';
      }

      AppMessage.show(
        context,
        message: message,
        type: MessageType.error,
      );
    } catch (error) {
      if (!mounted) return;

      AppMessage.show(
        context,
        message: 'Could not save your account. Please try again.',
        type: MessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
              children: [
                const SizedBox(height: 60),

                Text(
                  "Let's gather with",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                Text(
                  'Gather!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),

                const SizedBox(height: 40),

                AppTextField(
                  label: 'First Name',
                  hintText: 'Enter your first name',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Last Name',
                  hintText: 'Enter your last name',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

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

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password',
                  hintText: 'Create your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AppButton(text: 'Sign Up', onPressed: _signUp, isLoading: isLoading,),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      // Return to the login screen for existing users.
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text('Log in'),
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