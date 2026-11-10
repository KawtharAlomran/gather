
import 'package:flutter/material.dart';

enum MessageType {
  success,
  error,
}

class AppMessage extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onClose;

  const AppMessage({
    super.key,
    required this.message,
    this.type = MessageType.success,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isSuccess = type == MessageType.success;

    final Color backgroundColor = isSuccess
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    final Color foregroundColor = isSuccess
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    final IconData icon = isSuccess
        ? Icons.check_circle_outline
        : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foregroundColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                color: foregroundColor,
              ),
            ),
        ],
      ),
    );
  }
}
// Example 1: Success message (default)
//
// AppMessage(
//   message: 'Invitation accepted successfully!',
// ),
//
// Example 2: Error message
//
// AppMessage(
//   message: 'Something went wrong. Please try again.',
//   type: MessageType.error,
// ),
//
// Example 3: Message with close button
//
// AppMessage(
//   message: 'Gathering created successfully!',
//   onClose: () {
//     // Hide the message.
//   },
// ),
//
// Notes:
// - The default message type is success.
// - Supports success and error messages.
// - Colors and text styles are taken from the app theme.
// - The icon changes automatically based on the message type.
// - The close button is optional.
// - The message content can be customized for each screen.