import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I create a gathering?',
      'answer':
          'Open the Create Gathering option and enter the gathering details.',
    },
    {
      'question': 'Where can I find friends invitations?',
      'answer':
          'Open your invaitations, then you will see all of the inviations along with the name of the inviter and you can decline or accept the invitation.',
    },
    {
      'question': 'How can i add a freind?',
      'answer':
          'Open your Profile page and tap on Firends, then you can add a new firend using the Add New Freind button',
    },
    {
      'question': 'How do I log out?',
      'answer':
          'Open your Profile page and tap the Log out button.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: faqs.map((faq) {
          return Card(
            elevation: 0,
            color: Colors.transparent,
            margin: const EdgeInsets.only(bottom: 8),
            shape: const RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

              shape: const Border(),
              collapsedShape: const Border(),

              title: Text(
                faq['question']!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 19,
                ),
              ),

              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

