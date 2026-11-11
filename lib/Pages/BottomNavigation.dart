
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'InvitationPage.dart';
import 'profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int selectedIndex = 1;

  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget pageForTab(int index) {
    switch (index) {
      case 0:
        return InvitationPage();
      case 1:
        return const HomePage();
      case 2:
        return const ProfileScreen();
      default:
        return const HomePage();
    }
  }

  Widget tabNavigator(int index) {
    return Navigator(
      key: navigatorKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => pageForTab(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          tabNavigator(0),
          tabNavigator(1),
          tabNavigator(2),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            label: 'Invitations',
              tooltip: '',

          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
              tooltip: '',

          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
              tooltip: '',

          ),
        ],
      ),
    );
  }
}