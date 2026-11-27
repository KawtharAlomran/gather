import 'package:flutter/material.dart';

import '../shared_widgets/app_dialog.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_message.dart';
import '../data/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../shared_widgets/app_search_field.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<User> friends = [];
  bool isLoading = true;
  User? currentUser;
  // Stores the email entered in the Add Friend dialog.
  final TextEditingController _emailController = TextEditingController();

  // Reads registered users from the local JSON data.
  final FirebaseUserRepository _userRepository = FirebaseUserRepository();

  // Release the controller when the screen is removed.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final firebaseUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final loadedUser =
    await _userRepository.getUserById(firebaseUser.uid);

    final loadedFriends =
    await _userRepository.getFriends(firebaseUser.uid);

    if (!mounted) return;

    setState(() {
      currentUser = loadedUser;
      friends = loadedFriends;
      isLoading = false;
    });
  }

  // Open a dialog for searching for a friend by email.
  void _showAddFriendDialog() {
    // Clear the previous email before opening the dialog.
    _emailController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                // Close the Add Friend dialog.
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.highlight_off),
              ),
            ],
          ),
          content: AppSearchField(
            hintText: 'Search by email',
            controller: _emailController,
          ),
          actions: [
            AppButton(
              text: '+ Add New Friend',
              // Search for the entered email and add the user if found.
              onPressed: () {
                _searchAndAddFriend(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  // Search and add the matching user to the friends list.
  Future<void> _searchAndAddFriend(
    BuildContext dialogContext,
  ) async {
    final enteredEmail =
        _emailController.text.trim().toLowerCase();

    if (enteredEmail.isEmpty) {
      Navigator.pop(dialogContext);

      AppMessage.show(
        context,
        message: 'Please enter an email address.',
        type: MessageType.error,
      );
      return;
    }

    final firebaseUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final users = await _userRepository.getUsers();

    User? foundUser;

    for (final user in users) {
      if (user.email.toLowerCase() == enteredEmail) {
        foundUser = user;
        break;
      }
    }

    if (!mounted) return;

    if (foundUser == null) {
      Navigator.pop(dialogContext);

      AppMessage.show(
        context,
        message: 'This user is not registered.',
        type: MessageType.error,
      );
      return;
    }

    if (foundUser.id == firebaseUser.uid) {
      Navigator.pop(dialogContext);

      AppMessage.show(
        context,
        message: 'You cannot add yourself.',
        type: MessageType.error,
      );
      return;
    }

    final alreadyFriend = friends.any(
      (friend) => friend.id == foundUser!.id,
    );

    if (alreadyFriend) {
      Navigator.pop(dialogContext);

      AppMessage.show(
        context,
        message: 'This user is already your friend.',
        type: MessageType.error,
      );
      return;
    }

    await _userRepository.addFriend(
      firebaseUser.uid,
      foundUser.id,
    );

    if (!mounted) return;

    Navigator.pop(dialogContext);

    setState(() {
      friends.add(foundUser!);
    });

    AppMessage.show(
      context,
      message: 'Friend added successfully.',
      type: MessageType.success,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
        children: [
          const SizedBox(height: 16),

          const CircleAvatar(radius: 55, child: Icon(Icons.person, size: 60)),

          const SizedBox(height: 20),

          Text(
            currentUser?.fullName ?? 'User',
            style: Theme.of(context).textTheme.headlineLarge,
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppButton(
              text: 'Add New Friend',
              onPressed: _showAddFriendDialog,
            ),
          ),

          const SizedBox(height: 24),
          // Build one friend card for each friend in the list.
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : friends.isEmpty
                    ? const Center(
                        child: Text('No friends yet'),
                      )
                    : ListView.builder(
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
                                title: Text(friend.fullName),
                                subtitle: Text(friend.email),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AppDialog(
                                          title: 'Delete Friend',
                                          message:
                                              'Are you sure you want to delete ${friend.fullName} from your friends list?',
                                          cancelText: 'Cancel',
                                          confirmText: 'Delete',
                                          onConfirm: () async {
                                            final firebaseUser =
                                                firebase_auth.FirebaseAuth.instance.currentUser;

                                            if (firebaseUser == null) return;

                                            await _userRepository.removeFriend(
                                              firebaseUser.uid,
                                              friend.id,
                                            );

                                            if (!mounted) return;

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
          )
        ],
      ),
    );
  }
}