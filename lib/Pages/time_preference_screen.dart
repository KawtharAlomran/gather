import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gather/Pages/location_preference_screen.dart';
import 'package:gather/shared_widgets/app_button.dart';
import 'package:gather/shared_widgets/app_card.dart';

class TimePreferenceScreen extends StatefulWidget {
  const TimePreferenceScreen({super.key});

  @override
  State<TimePreferenceScreen> createState() =>
      _TimePreferenceScreenState();
}

class _TimePreferenceScreenState
    extends State<TimePreferenceScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final Set<DateTime> selectedDates = {};

  // Stores the selected time for each date
  final Map<DateTime, String> selectedTimes = {};

  final Set<String> selectedActivities = {'Dinner'};

  //For now the activities are hardcoded, but in the future, they will be fetched from the created gathering 
  final List<String> activities = [
    'Dinner',
    'Movie night',
    'Hiking',
    'Coffee',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // date selection
              AppCard(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime(2026),
                  lastDay: DateTime(2030),
                  focusedDay: focusedDay,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  selectedDayPredicate: (day) {
                    return selectedDates.any(
                      (date) => isSameDay(date, day),
                    );
                  },

                  // When a day is selected, update the selectedDay and focusedDay
                  onDaySelected: (day, newFocusedDay) {
                    setState(() {
                      focusedDay = newFocusedDay;
                      selectedDay = day;

                      DateTime? existingDate;

                      for (final date in selectedDates) {
                        if (isSameDay(date, day)) {
                          existingDate = date;
                          break;
                        }
                      }

                      if (existingDate != null) {
                        selectedDates.remove(existingDate);
                        selectedTimes.remove(existingDate);
                      } else {
                        selectedDates.add(day);

                        // Default time for a newly selected date
                        selectedTimes[day] = 'Afternoon';
                      }
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (selectedDates.isNotEmpty) ...[
                Text(
                  'Tap a date to edit preferences',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                ..._buildDatePreferenceCards(),
              ],

              const SizedBox(height: 16),

              // activity selection
              Text(
                'Preferred Activities',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Wrap the activities in a Wrap widget to allow for multiple lines
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activities.map((activity) {
                  final isSelected =
                      selectedActivities.contains(activity);

                  // Use ChoiceChip for each activity
                  // When selected, add to selectedActivities; 
                  // when deselected, remove from selectedActivities
                  return ChoiceChip(
                    label: Text(activity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedActivities.add(activity);
                        } else {
                          selectedActivities.remove(activity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              AppButton(
                text: 'Next',
                onPressed: selectedDates.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LocationPreferenceScreen(
                              selectedDates: selectedDates.toList(),
                              selectedTimes: selectedTimes,
                              selectedActivities:
                                  selectedActivities.toList(),
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDatePreferenceCards() {
    final dates = selectedDates.toList()
      ..sort((a, b) => a.compareTo(b));

    return dates.map((date) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text('Preferred Time'),

              const SizedBox(height: 8),

              Row(
                children: [
                  _timeButton(
                    date: date,
                    title: 'Morning',
                    subtitle: '8 AM – 12 PM',
                  ),
                  const SizedBox(width: 8),
                  _timeButton(
                    date: date,
                    title: 'Afternoon',
                    subtitle: '12 PM – 5 PM',
                  ),
                  const SizedBox(width: 8),
                  _timeButton(
                    date: date,
                    title: 'Evening',
                    subtitle: '5 PM – 10 PM',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  // Helper method to create a time selection button
  Widget _timeButton({
    required DateTime date,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedTimes[date] == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTimes[date] = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format a DateTime object into a readable string
  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // List of month names for formatting
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    
    // Return a formatted string like "Monday, January 1"
    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}';
  }
}