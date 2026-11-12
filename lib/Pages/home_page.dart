import 'package:flutter/material.dart';

import 'NotificationPage.dart';
import 'profile_screen.dart';
import 'create_gathering_screen.dart';

import '../data/repositories/gathering_details_repository.dart';
import '../models/gathering_model.dart';
import '../navigation/gathering_navigation.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/app_search_field.dart';
import '../shared_widgets/app_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock user ID. Replace with the logged-in user's ID later.
  final String currentUserId = 'user-manar';
  String _search = '';

  late Future<List<GatheringModel>> _gatheringsFuture;

  Future<void> _leaveGathering(GatheringModel gathering) async {
    await leaveGathering(gathering.id);
    if (!mounted) return;
    AppMessage.show(context, message: 'You left the gathering.');
    setState(() {
      _gatheringsFuture = loadGatherings();
    });
  }

  @override
  void initState() {
    super.initState();
    _gatheringsFuture = loadGatherings();
  }

  void _openGathering(GatheringModel gathering) {
    openGatheringDetails(
      context: context,
      gathering: gathering,
      currentUserId: currentUserId,
      onPlaceVoting: () {
        Navigator.of(context, rootNavigator: true)
            .pushNamed('/place-voting');      },
      onUpdatePreferences: () {
        Navigator.of(context, rootNavigator: true)
            .pushNamed('/update-preferences');
      },
      onChanged: (_) => setState(() {}),
      onLeaveGathering: _leaveGathering,
    );
  }

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
                  builder: (context) => const NotificationsPage(),
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
      body: FutureBuilder<List<GatheringModel>>(
        future: _gatheringsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load gatherings'));
          }
          final all = snapshot.data ?? <GatheringModel>[];
          final filtered = all.where((g) => g.title.toLowerCase().contains(_search.toLowerCase())).toList();
          final confirmed = filtered.where((g) => g.status == 'confirmed' || g.dateTime != null).toList();
          final planning = filtered.where((g) => g.status != 'confirmed' && g.dateTime == null).toList();
          final theme = Theme.of(context);
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('Good morning 👋', style: theme.textTheme.bodySmall),
            Text('Hey, welcome back!', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            AppSearchField(
              hintText: 'Search gatherings...',
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 24),
            Text('Upcoming Events', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (confirmed.isEmpty) const Text('No confirmed gatherings'),
            if (confirmed.isNotEmpty) SizedBox(height: 175, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: confirmed.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final g = confirmed[i];
                return SizedBox(
                  width: 235,
                  child: AppCard(
                    onTap: () => _openGathering(g),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONFIRMED', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 12),
                        Text(g.title, style: theme.textTheme.titleMedium, maxLines: 2),
                        const Spacer(),
                        if (g.dateTime != null)
                          Text(MaterialLocalizations.of(context).formatMediumDate(g.dateTime!.toLocal())),
                        Text(g.place ?? 'Place not specified', maxLines: 1),
                        Text('${g.attendingCount} attending'),
                      ],
                    ),
                  ),
                );
              },
            )),
            const SizedBox(height: 24),
            Text('Planning in Progress', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (planning.isEmpty) const Text('No gatherings in progress'),
            for (final g in planning) Padding(padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => _openGathering(g),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.title, style: theme.textTheme.titleMedium),
                          Text('Planning continues · ${g.planningProgress}%'),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(value: g.planningProgress.clamp(0, 100) / 100),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: SizedBox(
        width: 165,
        child: AppButton(
          text: '+ New Gathering',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateGathering()),
            );
          },
        ),
      ),
    );
  }
}
