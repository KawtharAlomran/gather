import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    const routes = ['/invitations', '/home', '/profile'];

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != selectedIndex) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.mail_outline),
          label: 'Invitations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}