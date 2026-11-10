
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
// Example usage:
//
// AppCard(
//   onTap: () {
//     // Handle card tap.
//   },
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text('Gathering Title'),
//       Text('Gathering Date'),
//     ],
//   ),
// ),
//
// Note:
// - The card color is automatically taken from the app theme.
// - The child can be customized based on the screen's needs.
// - The onTap parameter is optional.
// - Padding can be customized if needed.

// Example usage:
//
// AppCard(
//   onTap: () {
//     // Handle card tap.
//   },
//   child: Row(
//     children: [
//       Image.asset(
//         'assets/images/gathering.png',
//         width: 80,
//         height: 80,
//       ),
//       SizedBox(width: 12),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Gathering Title'),
//             Text('Gathering Date'),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),
//
// Notes:
// - The child accepts any Widget (Text, Row, Column, Image, list views, etc.).
// - A ListView can be used inside the card with proper size constraints.
// - The onTap parameter is optional.
// - Padding can be customized when needed.