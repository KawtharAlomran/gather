import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  // Optional button colors
  final Color? confirmColor;
  final Color? confirmTextColor;
  final Color? cancelColor;
  final Color? cancelTextColor;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Back',
    this.onCancel,
    this.confirmColor,
    this.confirmTextColor,
    this.cancelColor,
    this.cancelTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Close the dialog without confirming.
    void closeDialog() {
      Navigator.of(context).pop();
    }

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),

      titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),

      // Dialog title and close button
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),

          IconButton(
            onPressed: closeDialog,
            icon: const Icon(Icons.highlight_off),
            color: theme.colorScheme.onSurface,
            iconSize: 24,
            tooltip: 'Close',
          ),
        ],
      ),

      // Optional dialog message
      content: message == null || message!.isEmpty
          ? null
          : Text(message!, style: theme.textTheme.bodyMedium),

      // Dialog action buttons
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: cancelText,
                fullWidth: true,
                backgroundColor:
                    cancelColor ?? theme.colorScheme.surfaceContainerHighest,
                foregroundColor:
                    cancelTextColor ?? AppTheme.secondaryButtonTextColor,
                onPressed: onCancel ?? closeDialog,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppButton(
                text: confirmText,
                fullWidth: true,
                backgroundColor: confirmColor ?? theme.colorScheme.primary,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


// - The X button closes the dialog without confirming.
// - The dialog title uses titleMedium from the app theme.
// - The message is optional.
// - Uses the shared AppButton component.
// - Button background and text colors can be customized.
// - Default colors and text styles come from the app theme.
// - Border radius, padding, and spacing are defined here.
// - The layout is designed for mobile screens.
