
import 'package:flutter/material.dart';

class EmailInviteWidget extends StatefulWidget {
  final List<String> selectedEmails;
  final ValueChanged<List<String>> onEmailsChanged;
  final List<String> availableEmails;

  const EmailInviteWidget({
    super.key,
    required this.selectedEmails,
    required this.onEmailsChanged,
    this.availableEmails = const [],
  });

  @override
  State<EmailInviteWidget> createState() =>
      _EmailInviteWidgetState();
}

class _EmailInviteWidgetState extends State<EmailInviteWidget> {
  final TextEditingController emailController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Select or remove an email.
  void _toggleEmail(String email) {
    final updatedEmails = List<String>.from(widget.selectedEmails);

    if (updatedEmails.contains(email)) {
      updatedEmails.remove(email);
    } else {
      updatedEmails.add(email);
    }

    widget.onEmailsChanged(updatedEmails);
  }

  // Add a valid email that is not in the available list.
  void _addEmail() {
    final email = emailController.text.trim();

    final isValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!isValid) return;

    final alreadySelected = widget.selectedEmails.any(
      (item) => item.toLowerCase() == email.toLowerCase(),
    );

    if (!alreadySelected) {
      widget.onEmailsChanged([
        ...widget.selectedEmails,
        email,
      ]);
    }

    emailController.clear();

    setState(() {
      searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = searchText.trim().toLowerCase();

    final filteredEmails = widget.availableEmails
        .where((email) => email.toLowerCase().contains(query))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search email field
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Search by email',
            prefixIcon: const Icon(Icons.search),
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
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          onSubmitted: (_) => _addEmail(),
        ),

        const SizedBox(height: 12),

        // Matching email results
        if (query.isNotEmpty && filteredEmails.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEmails.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final email = filteredEmails[index];

              final isSelected = widget.selectedEmails.any(
                (item) =>
                    item.toLowerCase() == email.toLowerCase(),
              );

              return Container(
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
                    email,
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (_) => _toggleEmail(email),
                  ),
                  onTap: () => _toggleEmail(email),
                ),
              );
            },
          ),

        // Add an email manually if no matching user exists.
        if (query.isNotEmpty && filteredEmails.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              onPressed: _addEmail,
              icon: const Icon(Icons.add),
              label: Text(
                'Add "$searchText"',
              ),
            ),
          ),

        // Display selected emails
        if (widget.selectedEmails.isNotEmpty) ...[
          const SizedBox(height: 12),

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

// Example usage:
//
// EmailInviteWidget(
//   availableEmails: users.map((user) => user.email).toList(),
//   selectedEmails: selectedEmails,
//   onEmailsChanged: (emails) {
//     setState(() {
//       selectedEmails = emails;
//     });
//   },
// );
//
// Notes:
// - Supports searching existing emails.
// - Supports adding a new email manually.
// - Prevents duplicate selections.
// - Uses colors and text styles from the app theme.
// - Uses shrinkWrap to work inside scrollable pages.
// - Selected emails are managed by the parent widget.
