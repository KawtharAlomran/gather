
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;

import '../models/user_model.dart';
import '../data/repositories/user_repository.dart';

class EmailInviteWidget extends StatefulWidget {
  final List<String> selectedEmails;
  final ValueChanged<List<String>> onEmailsChanged;

  const EmailInviteWidget({
    super.key,
    required this.selectedEmails,
    required this.onEmailsChanged,
  });

  @override
  State<EmailInviteWidget> createState() =>
      _EmailInviteWidgetState();
}

class _EmailInviteWidgetState extends State<EmailInviteWidget> {
  final TextEditingController emailController =
      TextEditingController();

  final UserRepository _userRepository =
      FirebaseUserRepository();

  User? _foundUser;

  bool _isSearching = false;
  bool _hasSearched = false;

  String? _error;

  // Ignore outdated search results if the text changes.
  int _searchVersion = 0;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Search for a registered user by exact email.
  Future<void> _searchEmail() async {
    // Prevent duplicate searches.
    if (_isSearching) return;

    final email = emailController.text.trim().toLowerCase();

    final isValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!isValid) {
      setState(() {
        _error = 'Please enter a valid email address.';
        _foundUser = null;
        _hasSearched = false;
      });
      return;
    }

    final version = ++_searchVersion;

    setState(() {
      _isSearching = true;
      _error = null;
      _foundUser = null;
      _hasSearched = false;
    });

    try {
      final user =
          await _userRepository.findUserByEmail(email);

      if (!mounted || version != _searchVersion) return;

      final currentUserId =
          firebase_auth.FirebaseAuth.instance.currentUser?.uid;

      setState(() {
        _isSearching = false;
        _hasSearched = true;

        if (user != null && user.id == currentUserId) {
          _error = 'You cannot invite yourself.';
          _foundUser = null;
        } else {
          _foundUser = user;
        }
      });
    } catch (e) {
      if (!mounted || version != _searchVersion) return;

      debugPrint('Email search error: $e');

      setState(() {
        _isSearching = false;
        _hasSearched = false;
        _error = 'Unable to search. Please try again.';
      });
    }
  }

  // Select or remove an email.
  void _toggleEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();

    final updatedEmails =
        List<String>.from(widget.selectedEmails);

    final exists = updatedEmails.any(
      (item) =>
          item.toLowerCase() == normalizedEmail,
    );

    if (exists) {
      updatedEmails.removeWhere(
        (item) =>
            item.toLowerCase() == normalizedEmail,
      );
    } else {
      updatedEmails.add(normalizedEmail);
    }

    widget.onEmailsChanged(updatedEmails);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foundUser = _foundUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email search field.
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,

          // Show the Search action on the keyboard.
          textInputAction: TextInputAction.search,

          style: theme.textTheme.bodyMedium,

          // Search when Search/Enter is pressed.
          onSubmitted: (_) => _searchEmail(),

          onChanged: (_) {
            // Invalidate results from older searches.
            _searchVersion++;

            setState(() {
              _foundUser = null;
              _hasSearched = false;
              _error = null;
            });
          },

          decoration: InputDecoration(
            hintText: 'Search by email',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),

            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),

            // Search button or loading indicator.
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    tooltip: 'Search email',
                    onPressed: _searchEmail,
                  ),

            filled: true,
            fillColor: theme.colorScheme.surface,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Error message.
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),

        // No registered user found.
        if (_hasSearched &&
            foundUser == null &&
            _error == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Text(
              'No registered user found with this email.',
              style: theme.textTheme.bodyMedium,
            ),
          ),

        // Found user result.
        if (foundUser != null)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),

              title: Text(
                foundUser.fullName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                foundUser.email,
                style: theme.textTheme.bodyMedium,
              ),

              trailing: Checkbox(
                value: widget.selectedEmails.any(
                  (email) =>
                      email.toLowerCase() ==
                      foundUser.email.toLowerCase(),
                ),
                activeColor: theme.colorScheme.primary,
                onChanged: (_) =>
                    _toggleEmail(foundUser.email),
              ),

              onTap: () => _toggleEmail(foundUser.email),
            ),
          ),

        // Selected email addresses.
        if (widget.selectedEmails.isNotEmpty) ...[
          const SizedBox(height: 16),

          Text(
            'Selected Invitees',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedEmails.map((email) {
              return InputChip(
                label: Text(email),
                onDeleted: () => _toggleEmail(email),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
    