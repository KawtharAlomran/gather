
import 'package:flutter/material.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        //   the secondary button variant when available.
        AppButton(
          text: cancelText,
          fullWidth: false,
          onPressed: onCancel ?? () => Navigator.pop(context),
        ),

        // Support primary and danger variants when available.
        AppButton(
          text: confirmText,
          fullWidth: false,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

