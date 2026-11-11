import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gather/shared_widgets/app_button.dart';
import 'package:gather/shared_widgets/app_message.dart';

class LinkInviteWidget extends StatefulWidget {
  const LinkInviteWidget({super.key});

  @override
  State<LinkInviteWidget> createState() =>
      _LinkInviteWidgetState();
}

class _LinkInviteWidgetState
    extends State<LinkInviteWidget> {
  late String gatheringLink;

  @override
  void initState() {
    super.initState();
    gatheringLink = _generateLink();
  }

  // Generates a random link for the gathering
  String _generateLink() {
    const characters =
        'abcdefghijklmnopqrstuvwxyz'
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        '0123456789';

    final random = Random();

    // Generate a random 10-character code
    final code = List.generate(
      10,
      (_) => characters[
          random.nextInt(characters.length)],
    ).join();

    return 'gather.app/$code';
  }


  Future<void> _copyLink() async {
    await Clipboard.setData(
      ClipboardData(text: gatheringLink),
    );

    if (!mounted) return;

    AppMessage.show(
      context,
      message: 'Link copied successfully!',
      type: MessageType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COPY LINK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            gatheringLink,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 16),

          AppButton(
            text: 'Copy Link',
            onPressed: _copyLink,
          ),
          
        ],
      ),
    );
  }
}