import 'package:flutter/material.dart';
import 'package:gather/Pages/friends_screen.dart';
import 'package:gather/Pages/login_screen.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/repositories/user_repository.dart';
import '../models/user_model.dart';
import 'help_support_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controls whether notifications are enabled.
  bool notificationsEnabled = true;

  User? currentUser;
  bool isLoading = true;
  String? selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    final loadedUser = await FirebaseUserRepository()
        .getUserById(firebaseUser.uid);

    if (!mounted) return;

    setState(() {
      currentUser = loadedUser;
      selectedAvatar = loadedUser?.avatar;
      notificationsEnabled = loadedUser?.notificationsEnabled ?? true;
      isLoading = false;
    });
  }
  Future<void> _showAvatarPicker() async {
    const avatarOptions = [
      {
        'name': 'blue',
        'color': Color.fromARGB(255, 114, 175, 225),
      },
      {
        'name': 'orange',
        'color': Color.fromARGB(255, 244, 160, 33),
      },
      {
        'name': 'green',
        'color': Color.fromARGB(255, 45, 131, 48),
      },
      {
        'name': 'purple',
        'color': Color.fromARGB(255, 126, 41, 142),
      },
      {
        'name': 'pink',
        'color': Color.fromARGB(255, 242, 82, 135),
      },
      {
        'name': 'teal',
        'color': Color.fromARGB(255, 7, 159, 144),
      },
      {
        'name': 'default',
        'color': Colors.grey,
      },
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose your avatar'),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: avatarOptions.map((avatar) {
              return GestureDetector(
                onTap: () async {
                  final avatarName = avatar['name'] as String;
                  final firebaseUser =
                      firebase_auth.FirebaseAuth.instance.currentUser;

                  Navigator.pop(dialogContext);

                  if (firebaseUser == null) return;

                  await FirebaseUserRepository().updateAvatar(
                    firebaseUser.uid,
                    avatarName,
                  );

                  if (!mounted) return;

                  setState(() {
                    selectedAvatar = avatarName;
                  });
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: avatar['color'] as Color,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _avatarColor(String? avatar) {
    switch (avatar) {
      case 'blue':
        return Color.fromARGB(255, 104, 151, 189);
      case 'orange':
        return Color.fromARGB(255, 238, 173, 74);
      case 'green':
        return Color.fromARGB(255, 22, 85, 24);
      case 'purple':
        return Color.fromARGB(255, 85, 21, 96);
      case 'pink':
        return Color.fromARGB(255, 242, 82, 135);
      case 'teal':
        return Color.fromARGB(255, 7, 159, 144);
      default:
        return Colors.grey.shade200;
    }
  }
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
              // Display the user's profile image and edit button.
              Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: _avatarColor(selectedAvatar),
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: selectedAvatar == 'default' || selectedAvatar == null
                          ? Colors.grey.shade500
                          : Colors.white,                    ),
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
                        onPressed: _showAvatarPicker,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              if (isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  currentUser?.fullName ?? 'User',
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
                        // Update the notification setting and refresh the UI.
                        onChanged: (value) async {
                          setState(() {
                            notificationsEnabled = value;
                          });

                          final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

                          if (firebaseUser == null) return;

                          await FirebaseUserRepository().updateNotificationPreference(
                            firebaseUser.uid,
                            value,
                          );
                        },
                      ),
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
                      // Open the user's friends list.
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportPage(),
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.contact_support_outlined),
                      title: const Text('Contact us'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final emailUri = Uri(
                          scheme: 'mailto',
                          path: 'gather.support@gmail.com',
                          queryParameters: {
                            'subject': 'Gather App Support',
                          },
                        );

                        await launchUrl(emailUri);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              AppButton(
                text: 'Log out',
                onPressed: () async {
                  await firebase_auth.FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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