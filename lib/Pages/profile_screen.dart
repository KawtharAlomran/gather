import 'package:flutter/material.dart';
import 'package:gather/Pages/friends_screen.dart';
import 'package:gather/Pages/language_screen.dart';
import 'package:gather/Pages/login_screen.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primary,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        color: Colors.white,
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Image selection will be added later.
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'User Name',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 28),

              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('Notifications'),
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                        },
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.people_outline),
                      title: const Text('Friends'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FriendsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),

                    ListTile(
                      leading: const Icon(Icons.contact_support_outlined),
                      title: const Text('Contact us'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              AppButton(
                text: 'Log out',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}