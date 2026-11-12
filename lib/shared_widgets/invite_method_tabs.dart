import 'package:flutter/material.dart';

enum InviteMethod {
  friends,
  email,
  link,
}

class InviteMethodTabs extends StatefulWidget {
  final InviteMethod selectedMethod;
  final ValueChanged<InviteMethod> onChanged;

  const InviteMethodTabs({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  State<InviteMethodTabs> createState() =>
      _InviteMethodTabsState();
}

class _InviteMethodTabsState
    extends State<InviteMethodTabs> {
  InviteMethod? hoveredMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEEA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Friends List',
            method: InviteMethod.friends,
          ),
          _buildTab(
            label: 'Email',
            method: InviteMethod.email,
          ),
          _buildTab(
            label: 'Link',
            method: InviteMethod.link,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required InviteMethod method,
  }) {
    final bool isSelected =
        widget.selectedMethod == method;

    final bool isHovered = hoveredMethod == method;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveredMethod = method;
          });
        },
        onExit: (_) {
          setState(() {
            hoveredMethod = null;
          });
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onChanged(method),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : isHovered
                      ? const Color(0xFFE8E3DE)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: const Color(0xFF332F2D),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//The widget is a stateless widget that displays three tabs for selecting an invite method: Friends List, Email, and Link. 
//It takes in the currently selected method and a callback function to handle changes in selection. 
//It can used as follows:
// InviteMethodTabs(
//   selectedMethod: selectedMethod,
//   onChanged: (method) {
//     setState(() {
//       selectedMethod = method;
//     });
//   },
// ),