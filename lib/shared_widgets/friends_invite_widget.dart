import 'package:flutter/material.dart';

class Invitee {
  final String id;
  final String name;
  final String? email;

  const Invitee({
    required this.id,
    required this.name,
    this.email,
  });
}

class FriendsInviteWidget extends StatefulWidget {
  final List<Invitee> friends;
  final Set<String> selectedFriendIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const FriendsInviteWidget({
    super.key,
    required this.friends,
    required this.selectedFriendIds,
    required this.onSelectionChanged,
  });

  @override
  State<FriendsInviteWidget> createState() =>
      _FriendsInviteWidgetState();
}

class _FriendsInviteWidgetState
    extends State<FriendsInviteWidget> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredFriends = widget.friends.where((friend) {
      final query = searchText.toLowerCase();

      return friend.name.toLowerCase().contains(query) ||
          (friend.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search friends',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
        ),

        const SizedBox(height: 12),

        Expanded(
          child: ListView.separated(
            itemCount: filteredFriends.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              final isSelected = widget.selectedFriendIds
                  .contains(friend.id);

              return ListTile(
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: CircleAvatar(
                  child: Text(
                    friend.name.isNotEmpty
                        ? friend.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(friend.name),
                subtitle: friend.email == null
                    ? null
                    : Text(friend.email!),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    _toggleFriend(friend.id);
                  },
                ),
                onTap: () {
                  _toggleFriend(friend.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _toggleFriend(String friendId) {
    final updatedIds =
        Set<String>.from(widget.selectedFriendIds);

    if (updatedIds.contains(friendId)) {
      updatedIds.remove(friendId);
    } else {
      updatedIds.add(friendId);
    }

    widget.onSelectionChanged(updatedIds);
  }
}

// The widget can be used in the create gathering screen as follows:

  // Set<String> selectedFriendIds = {};
  // FriendsInviteWidget(
  //   friends: const [
  //     Invitee(
  //       id: '1',
  //       name: 'Sarah',
  //       email: 'sarah@gmail.com',
  //     ),
  //     Invitee(
  //       id: '2',
  //       name: 'Manar',
  //       email: 'manar@gmail.com',
  //     ),
  //     Invitee(
  //       id: '3',
  //       name: 'Shahad',
  //       email: 'shahad@gmail.com',
  //     ),
  //   ],
  //   selectedFriendIds: selectedFriendIds,
  //   onSelectionChanged: (updatedIds) {
  //     setState(() {
  //       selectedFriendIds = updatedIds;
  //     });
  //   },
  // ),