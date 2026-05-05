import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/providers/all_pool_members_provider.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../shared_expenses/data/shared_expenses_models.dart';
import '../../shared_expenses/data/shared_expenses_providers.dart';
import '../data/leave_providers.dart';

class AddLeaveEntryPage extends ConsumerStatefulWidget {
  final String userId;
  final int year;

  const AddLeaveEntryPage({
    super.key,
    required this.userId,
    required this.year,
  });

  @override
  ConsumerState<AddLeaveEntryPage> createState() => _AddLeaveEntryPageState();
}

class _AddLeaveEntryPageState extends ConsumerState<AddLeaveEntryPage> {
  late TextEditingController _descriptionController;
  late TextEditingController _daysController;
  late DateTime _selectedDate;
  late String _selectedUserId;
  String? _selectedTripId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _daysController = TextEditingController(text: '1');
    _selectedDate = DateTime.now();
    _selectedUserId = widget.userId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(widget.year, 1, 1),
      lastDate: DateTime(widget.year, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter a description');
      return;
    }

    final days = int.tryParse(_daysController.text);
    if (days == null || days <= 0) {
      _showError('Please enter a valid number of days');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(leaveEntriesByYearProvider((_selectedUserId, widget.year)).notifier)
          .addEntry(
            description: _descriptionController.text.trim(),
            daysUsed: days,
            leaveDate: _selectedDate,
            tripId: _selectedTripId,
          );

      ref.invalidate(leaveTrackingProvider((_selectedUserId, widget.year)));
      ref.invalidate(leaveSummaryProvider((_selectedUserId, widget.year)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave entry added successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('Failed to add leave: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(allPoolMembersProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final tripsAsync = ref.watch(allTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Leave Entry'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            membersAsync.maybeWhen(
              data: (members) {
                final users = members.take(2).toList();
                if (users.isEmpty) return const SizedBox.shrink();
                if (!users.any((u) => u.id == _selectedUserId)) {
                  _selectedUserId = users.first.id;
                }
                return _buildUserField(context, theme, users, currentUserAsync);
              },
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Vacation, Personal leave',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppTheme.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days Used',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _daysController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(
                    hintText: '1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                      size: 18,
                      color: AppTheme.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Date',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('MMMM d, yyyy').format(_selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            tripsAsync.when(
              data: (trips) {
                final yearTrips = _filterTripsForYear(trips, widget.year);
                return _buildTripField(theme, yearTrips);
              },
              loading: () => _buildTripField(theme, const []),
              error: (error, stackTrace) => _buildTripField(theme, const []),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Add Leave Entry',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserField(
    BuildContext context,
    ThemeData theme,
    List<AppUser> users,
    AsyncValue currentUserAsync,
  ) {
    final currentUserId = currentUserAsync.maybeWhen(
      data: (u) => u.id,
      orElse: () => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey<String>(_selectedUserId),
          initialValue: _selectedUserId,
          items: users
              .map(
                (u) => DropdownMenuItem<String>(
                  value: u.id,
                  child: Text(getDisplayName(u.id, currentUserId, {u.id: u.name})),
                ),
              )
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() => _selectedUserId = value);
                },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            prefixIcon: Icon(
              Icons.person_rounded,
              size: 18,
              color: AppTheme.accent.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripField(ThemeData theme, List<TripSummary> yearTrips) {
    final options = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('No trip'),
      ),
      ...yearTrips
          .where((t) => t.tripId != null && t.tripName != null)
          .map(
            (t) => DropdownMenuItem<String?>(
              value: t.tripId,
              child: Text(t.tripName!),
            ),
          ),
    ];

    final selectedStillExists = options.any((item) => item.value == _selectedTripId);
    final selectedTripValue = selectedStillExists ? _selectedTripId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip (Optional)',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          key: ValueKey<String?>('trip-$selectedTripValue'),
          initialValue: selectedTripValue,
          items: options,
          onChanged: _isSubmitting
              ? null
              : (value) {
                  setState(() => _selectedTripId = value);
                },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            prefixIcon: Icon(
              Icons.luggage_rounded,
              size: 18,
              color: AppTheme.accent.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  List<TripSummary> _filterTripsForYear(List<TripSummary> trips, int year) {
    return trips.where((trip) {
      final start = trip.startDate;
      final end = trip.endDate;
      if (start == null && end == null) return false;
      if (start != null && start.year == year) return true;
      if (end != null && end.year == year) return true;
      if (start != null && end != null) {
        return start.year <= year && end.year >= year;
      }
      return false;
    }).toList();
  }
}
