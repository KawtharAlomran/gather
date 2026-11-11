import 'package:flutter/material.dart';
import '../shared_widgets/app_dialog.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  final List<Map<String, String>> friends = [
    {
      'name': 'Naba Al Antaif',
      'email': 'naba@example.com',
    },
    {
      'name': 'Sarah Ahmed',
      'email': 'sarah@example.com',
    },
    {
      'name': 'Manar Ali',
      'email': 'manar@example.com',
    },
  ];
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          const CircleAvatar(
            radius: 55,
            child: Icon(
              Icons.person,
              size: 60,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Nour Al Sulais',
            style: Theme.of(context).textTheme.headlineLarge,
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppButton(
              text: 'Add New Friend',
              onPressed: (){},
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        friend['name']!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        friend['email']!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AppDialog(
                                title: 'Delete Friend',
                                message:
                                    'Are you sure you want to delete ${friend['name']} from your friends list?',
                                cancelText: 'Cancel',
                                confirmText: 'Delete',
                                onConfirm: () {
                                  setState(() {
                                    friends.removeAt(index);
                                  });

                                  Navigator.pop(dialogContext);
                                  AppMessage.show(
                                    context,
                                    message: 'Friend deleted successfully.',
                                    type: MessageType.success,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}