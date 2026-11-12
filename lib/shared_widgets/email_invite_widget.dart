import 'package:flutter/material.dart';

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

class _EmailInviteWidgetState
    extends State<EmailInviteWidget> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void addEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      return;
    }

    if (widget.selectedEmails.contains(email)) {
      emailController.clear();
      return;
    }

    final updatedEmails = [
      ...widget.selectedEmails,
      email,
    ];

    widget.onEmailsChanged(updatedEmails);
    emailController.clear();
  }

  void removeEmail(String email) {
    final updatedEmails = widget.selectedEmails
        .where((item) => item != email)
        .toList();

    widget.onEmailsChanged(updatedEmails);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onSubmitted: (_) => addEmail(),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: addEmail,
                child: const Text('Add'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: widget.selectedEmails.isEmpty
              ? const Center(
                  child: Text(
                    'No email addresses added',
                  ),
                )
              : ListView.separated(
                  itemCount: widget.selectedEmails.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final email =
                        widget.selectedEmails[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor:
                                Color(0xFFFF6F5B),
                            child: Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              removeEmail(email);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}