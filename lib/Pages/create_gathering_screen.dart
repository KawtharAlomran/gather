
import 'package:flutter/material.dart';

import '../models/gathering_model.dart';
import '../data/repositories/gather_repository.dart';

import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_message.dart';

import 'time_preference_screen.dart';

// TODO: Update imports to match the actual widget locations.
import '../shared_widgets/email_invite_widget.dart';
import '../shared_widgets/link_invite_widget.dart';

class CreateGathering extends StatefulWidget {
  final GatheringRepository repository;

  CreateGathering({
    super.key,
    GatheringRepository? repository,
  }) : repository = repository ?? MockGatheringRepository();

  @override
  State<CreateGathering> createState() => _CreateGatheringState();
}

class _CreateGatheringState extends State<CreateGathering> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _activityController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  RangeValues _budgetRange = const RangeValues(50, 200);

  final List<String> _activities = [];
  List<String> _selectedEmails = [];
  List<String> _selectedFriendIds = [];

  int _selectedInviteMethod = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  // Select the gathering date range.
  Future<void> _selectDates() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (range == null || !mounted) return;

    setState(() {
      _startDate = range.start;
      _endDate = range.end;
    });
  }

  // Add an activity.
  void _addActivity() {
    final activity = _activityController.text.trim();

    if (activity.isEmpty) return;

    final exists = _activities.any(
      (item) => item.toLowerCase() == activity.toLowerCase(),
    );

    if (exists) {
      AppMessage.show(
        context,
        message: 'This activity has already been added.',
        type: MessageType.error,
      );
      return;
    }

    setState(() {
      _activities.add(activity);
    });

    _activityController.clear();
  }

  // Remove an activity.
  void _removeActivity(String activity) {
    setState(() {
      _activities.remove(activity);
    });
  }

  // Save gathering through the repository.
  Future<void> _createGathering() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      AppMessage.show(
        context,
        message: 'Please select the gathering dates.',
        type: MessageType.error,
      );
      return;
    }

    if (_activities.isEmpty) {
      AppMessage.show(
        context,
        message: 'Please add at least one activity.',
        type: MessageType.error,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final gathering = Gathering(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),

        // TODO: Replace with authenticated user data.
        creatorEmail: 'nour@example.com',

        participantIds: List.from(_selectedFriendIds),
        startDate: _startDate,
        endDate: _endDate,
        minBudget: _budgetRange.start,
        maxBudget: _budgetRange.end,
        activities: List.from(_activities),
      );

      await widget.repository.createGathering(gathering);

      if (!mounted) return;

      AppMessage.show(
        context,
        message: 'Gathering created successfully!',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimePreferenceScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      AppMessage.show(
        context,
        message: 'Unable to create gathering. Please try again.',
        type: MessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Build invitation method selection.
  Widget _buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invite People',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 12),

        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text('Friends'),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Email'),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Link'),
            ),
          ],
          selected: {_selectedInviteMethod},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedInviteMethod = selection.first;
            });
          },
        ),

        const SizedBox(height: 16),

        if (_selectedInviteMethod == 0)
          // TODO: Replace with FriendsInviteWidget.
          Text(
            'Friends selection will be connected here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

        if (_selectedInviteMethod == 1)
          SizedBox(
            height: 260,
            child: EmailInviteWidget(
              selectedEmails: _selectedEmails,
              onEmailsChanged: (emails) {
                setState(() {
                  _selectedEmails = emails;
                });
              },
            ),
          ),

        if (_selectedInviteMethod == 2)
          const LinkInviteWidget(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Gathering'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Plan a Gathering',
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 24),

              Text(
                'Gathering Name',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter gathering name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a gathering name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Date Range',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _selectDates,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _startDate == null
                      ? 'Select Dates'
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        ' - '
                        '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Budget Range',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 8),

              Text(
                '${_budgetRange.start.round()} - '
                '${_budgetRange.end.round()} SAR',
                style: theme.textTheme.bodyMedium,
              ),

              RangeSlider(
                values: _budgetRange,
                min: 0,
                max: 1000,
                divisions: 20,
                onChanged: (values) {
                  setState(() {
                    _budgetRange = values;
                  });
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Activities',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _activityController,
                      decoration: const InputDecoration(
                        hintText: 'Enter an activity',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addActivity(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton.filled(
                    onPressed: _addActivity,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activities.map((activity) {
                  return InputChip(
                    label: Text(activity),
                    onDeleted: () => _removeActivity(activity),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              _buildInviteSection(),

              const SizedBox(height: 32),

              AppButton(
                text: 'Create Gathering',
                isLoading: _isSaving,
                onPressed: _createGathering,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
