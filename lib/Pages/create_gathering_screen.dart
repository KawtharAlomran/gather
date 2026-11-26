
import 'package:flutter/material.dart';

import '../data/repositories/user_repository.dart';
import '../data/repositories/gather_repository.dart';
import '../shared_widgets/app_button.dart';
import '../shared_widgets/app_message.dart';
import '../theme/app_theme.dart';

import 'time_preference_screen.dart';

import '../shared_widgets/email_invite_widget.dart';
import '../shared_widgets/link_invite_widget.dart';

class CreateGathering extends StatefulWidget {
  const CreateGathering({super.key});

  @override
  State<CreateGathering> createState() =>
      _CreateGatheringState();
}

class _CreateGatheringState extends State<CreateGathering> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _activityController = TextEditingController();

  final UserRepository _userRepository =
      FirebaseUserRepository();

  final GatheringRepository _gatheringRepository =
      FirestoreGatheringRepository();

  DateTime? _startDate;
  DateTime? _endDate;

  RangeValues _budgetRange = const RangeValues(20, 50);

  final List<String> _activities = [];
  List<String> _selectedEmails = [];

  int _selectedInviteMethod = 1;

  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  // Select gathering dates.
  Future<void> _selectDates() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(
                  start: _startDate!,
                  end: _endDate!,
                )
              : null,
    );

    if (range == null || !mounted) return;

    setState(() {
      _startDate = range.start;
      _endDate = range.end;
    });
  }

  // Add an activity without duplicates.
  void _addActivity() {
    final activity = _activityController.text.trim();

    if (activity.isEmpty) return;

    final exists = _activities.any(
      (item) =>
          item.toLowerCase() == activity.toLowerCase(),
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

  // Validate, create gathering and send invitations.
  Future<void> _continue() async {
    if (_isCreating) return;

    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      AppMessage.show(
        context,
        message: 'Please select the gathering dates.',
        type: MessageType.error,
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final inviteeIds = <String>{};

      // Find registered users by their email addresses.
      for (final email in _selectedEmails) {
        final user =
            await _userRepository.findUserByEmail(email);

        if (user == null) {
          throw StateError(
            'Registered user not found: $email',
          );
        }

        inviteeIds.add(user.id);
      }

      // Save gathering and invitations atomically.
      final gathering =
          await _gatheringRepository
              .createGatheringWithInvitations(
        title: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        minBudget: _budgetRange.start,
        maxBudget: _budgetRange.end,
        activities: List<String>.from(_activities),
        inviteeIds: inviteeIds.toList(),
      );

      if (!mounted) return;

      AppMessage.show(
        context,
        message:
            'Gathering created and invitations sent successfully!',
        type: MessageType.success,
      );

      debugPrint(
        'Created gathering ID: ${gathering.id}',
      );

      // Continue to the next planning screen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimePreferenceScreen( gathering: gathering),
        ),
      );
    } catch (e) {
      debugPrint('Create gathering error: $e');

      if (!mounted) return;

      AppMessage.show(
        context,
        message:
            'Unable to create gathering. Please try again.',
        type: MessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Shared soft input decoration.
  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 1,
        ),
      ),
    );
  }

  // Full-width invitation method tabs.
  Widget _buildInviteTabs() {
    final theme = Theme.of(context);

    const labels = [
      'Friends List',
      'Email',
      'Link',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryButtonColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (int index = 0;
              index < labels.length;
              index++)
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedInviteMethod = index;
                  });
                },
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedInviteMethod == index
                            ? theme.colorScheme.surface
                            : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontWeight:
                          _selectedInviteMethod == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Display the selected invitation method.
  Widget _buildInviteContent() {
    if (_selectedInviteMethod == 0) {
      // Friends integration will be added later.
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'Friends list will be available soon.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_selectedInviteMethod == 1) {
      return EmailInviteWidget(
        selectedEmails: _selectedEmails,
        onEmailsChanged: (emails) {
          setState(() {
            _selectedEmails = emails;
          });
        },
      );
    }

    return const LinkInviteWidget();
  }

  // Display selected invitee count.
  Widget _buildSelectedInvitees() {
    final count = _selectedEmails.length;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'View selected invitees',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Plan a Gathering',
          style: theme.textTheme.titleMedium,
        ),
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
              // Gathering name
              Text(
                'GATHERING NAME',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Enter gathering name',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a gathering name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date range labels
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'DATE FROM',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TO',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      _formatDate(_startDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      _formatDate(_endDate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Budget range
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BUDGET RANGE',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${_budgetRange.start.round()} - '
                    '${_budgetRange.end.round()} SAR',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              RangeSlider(
                values: _budgetRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: theme.colorScheme.primary,
                onChanged: (values) {
                  setState(() {
                    _budgetRange = values;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Activities
              Text(
                'ACTIVITIES',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _activityController,
                      decoration: _inputDecoration(
                        'Add an activity',
                      ),
                      onSubmitted: (_) =>
                          _addActivity(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 85,
                    child: AppButton(
                      text: 'Add',
                      fullWidth: true,
                      onPressed: _addActivity,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _activities.map((activity) {
                  return InputChip(
                    label: Text(activity),
                    onDeleted: () =>
                        _removeActivity(activity),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    backgroundColor:
                        theme.colorScheme.surface,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Invite people
              Text(
                'INVITE PEOPLE',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 10),

              _buildInviteTabs(),

              const SizedBox(height: 14),

              _buildInviteContent(),

              const SizedBox(height: 14),

              _buildSelectedInvitees(),

              const SizedBox(height: 20),

              AppButton(
                text: 'Create',
                isLoading: _isCreating,
                onPressed:
                    _isCreating ? null : _continue,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Soft date selection field.
  Widget _dateField(String label) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _selectDates,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
