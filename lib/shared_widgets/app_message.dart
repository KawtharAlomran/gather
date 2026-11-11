import 'package:flutter/material.dart';
import 'dart:async';

enum MessageType { success, error }

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

  static OverlayEntry? _currentOverlay;
  static Timer? _dismissTimer;

  // Display a message at the top of the screen.
  static void show(
    BuildContext context, {
    required String message,
    MessageType type = MessageType.success,
  }) {
    // Cancel the timer of the previous message.
    _dismissTimer?.cancel();
    _dismissTimer = null;

    // Remove any previously displayed message.
    _currentOverlay?.remove();
    _currentOverlay?.dispose();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    void closeMessage() {
      if (_currentOverlay != entry) return;

      _dismissTimer?.cancel();
      _dismissTimer = null;

      entry.remove();
      entry.dispose();
      _currentOverlay = null;
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: MediaQuery.paddingOf(overlayContext).top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: AppMessage(
                message: message,
                type: type,
                onClose: closeMessage,
              ),
            ),
          ),
        );
      },
    );

    _currentOverlay = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(
      const Duration(seconds: 2),
      closeMessage,
    );
  }

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
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: foregroundColor),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: foregroundColor),
          ),
        ],
      ),
    );
  }
}

// Example 1: Success message (default)
//
// AppMessage.show(
//   context,
//   message: 'Invitation accepted successfully!',
// );
//
// Example 2: Error message
//
// AppMessage.show(
//   context,
//   message: 'Something went wrong. Please try again.',
//   type: MessageType.error,
// );
//
// Notes:
// - Messages appear automatically at the top of the screen.
// - Success is the default message type.
// - Only one message is displayed at a time.
// - Messages can be dismissed using the close button.
// - Colors and text styles are taken from the app theme.
// - No Stack, Positioned, or setState is needed in the calling screen.
