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

  String selectedTime = 'Afternoon';
  final Set<String> selectedActivities = {'Dinner'};

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
                  onDaySelected: (day, newFocusedDay) {
                    setState(() {
                      focusedDay = newFocusedDay;
                      selectedDay = day;

                      final alreadySelected = selectedDates.any(
                        (date) => isSameDay(date, day),
                      );

                      if (alreadySelected) {
                        selectedDates.removeWhere(
                          (date) => isSameDay(date, day),
                        );
                      } else {
                        selectedDates.add(day);
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

              if (selectedDay != null) ...[
                Text(
                  'Tap a date to edit preferences',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(selectedDay!),
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
                            title: 'Morning',
                            subtitle: '8 AM – 12 PM',
                          ),
                          const SizedBox(width: 8),
                          _timeButton(
                            title: 'Afternoon',
                            subtitle: '12 PM – 5 PM',
                          ),
                          const SizedBox(width: 8),
                          _timeButton(
                            title: 'Evening',
                            subtitle: '5 PM – 10 PM',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Text(
                'Preferred Activities',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activities.map((activity) {
                  final isSelected =
                      selectedActivities.contains(activity);

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
                              selectedTime: selectedTime,
                              selectedActivities: selectedActivities.toList(),
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

  Widget _timeButton({
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedTime == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTime = title;
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
                  color: isSelected
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}';
  }
}