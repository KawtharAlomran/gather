import 'package:flutter/material.dart';
import 'NotificationPage.dart';
import 'profile_screen.dart';
import 'create_gathering_screen.dart'; 
import 'app_bottom_nav.dart';
import 'gathering_details_screen.dart';
import 'invitee_gather_details_screen.dart'; 



class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Center(
        child: Column( 
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),
            const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GatheringDetailsScreen(), 
                  ),
                );
              },
              child: const Text('Upcoming Events'),
            ),

            const SizedBox(height: 20),

             ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InviteeGatherDetails(),
                  ),
                );
              },
              child: const Text('Planning in Progress'),
            ),

          ],

        ) 
        
      ),
      bottomNavigationBar: const AppBottomNav(
      selectedIndex: 1,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGathering(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Gathering'),
      ),
    );
  }
}