import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../shared/providers/current_user_provider.dart';
import '../../../shared/providers/all_pool_members_provider.dart';
import '../data/transaction_service.dart';
import '../../shell/shell_page.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key, required this.args});

  final TransactionFormArgs args;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  late String _transactionType;
  late DateTime _selectedDate;
  late DateTime? _endDate;
  late double _amount;
  late String _description;
  late String _tripName;
  late String _selectedUserId; // Current selected user for "By" field
  late bool _isFundPool; // Toggle for FUNd vs user
  bool _isSubmitting = false; // Track form submission state

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tripNameController = TextEditingController();
  final _notesController = TextEditingController();
  late FocusNode _descriptionFocusNode;

  List<Map<String, dynamic>> _createdTransactions = [];
  List<Map<String, dynamic>> _createdTrips = [];

  @override
  void initState() {
    super.initState();
    _transactionType = widget.args.type;
    _selectedDate = widget.args.initialMonth;
    _endDate = null;
    _amount = 0;
    _description = '';
    _tripName = '';
    _selectedUserId = '';
    _isFundPool = false;
    _createdTransactions = [];
    _createdTrips = [];
    
    _descriptionFocusNode = FocusNode();
    
    // Auto-focus description field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tripNameController.dispose();
    _notesController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }



  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 180)), // Limit to 6 months in future
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: now.add(const Duration(days: 180)), // Limit to 6 months in future
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 180)), // Limit to 6 months in future
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm({bool addAnother = false}) {
    if (_transactionType == 'add_trip') {
      _submitTrip(addAnother);
    } else {
      _submitTransaction(addAnother);
    }
  }

  void _submitTransaction(bool addAnother) {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    _amount = double.tryParse(_amountController.text) ?? 0;

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    // Validate user selection for user-specific transactions
    if (!_isFundPool && _selectedUserId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    // Validate: Deposit must always have a user (not FUNd)
    if (_transactionType == 'deposit' && _isFundPool) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deposit must be by a specific user, not FUNd')),
      );
      return;
    }

    _submitToDatabase(addAnother);
  }

  Future<void> _submitToDatabase(bool addAnother) async {
    if (_isSubmitting) return; // Prevent duplicate submissions
    
    try {
      setState(() => _isSubmitting = true);
      
      final monthKey = app_date_utils.DateUtils.toMonthKey(_selectedDate);
      final userId = _isFundPool ? null : _selectedUserId.trim();
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
      final description = _descriptionController.text.trim();

      if (_transactionType == 'personal_expense') {
        await ref.read(transactionServiceProvider).createPersonalExpense(
          userId: userId!,
          amount: _amount,
          description: description,
          date: _selectedDate,
          monthKey: monthKey,
          notes: notes,
        );
      } else if (_transactionType == 'shared_expense') {
        await ref.read(transactionServiceProvider).createSharedExpense(
          isFundPool: _isFundPool,
          userId: userId,
          amount: _amount,
          description: description,
          date: _selectedDate,
          monthKey: monthKey,
          notes: notes,
        );
      } else if (_transactionType == 'deposit') {
        await ref.read(transactionServiceProvider).createDeposit(
          userId: userId!,
          amount: _amount,
          description: description,
          date: _selectedDate,
          monthKey: monthKey,
          notes: notes,
        );
      }

      final transaction = {
        'type': _transactionType,
        'amount': _amount,
        'description': description,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'by': _isFundPool ? 'FUNd Pool' : 'User: $userId',
      };

      if (mounted) {
        setState(() {
          _createdTransactions.add(transaction);
          _isSubmitting = false;
        });
      }

      if (addAnother) {
        _amountController.clear();
        _descriptionController.clear();
        _notesController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added! Ready for next entry')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction saved')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      final appException = e is Exception ? AppException.fromError(e) : AppException.fromError(Exception(e));
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appException.getUserFriendlyMessage())),
        );
      }
    }
  }

  void _submitTrip(bool addAnother) {
    if (_tripNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a trip name')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    // Validate: end date must be after start date
    if (_endDate!.isBefore(_selectedDate) || _endDate!.isAtSameMomentAs(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    _submitTripToDatabase(addAnother);
  }

  Future<void> _submitTripToDatabase(bool addAnother) async {
    if (_isSubmitting) return; // Prevent duplicate submissions
    
    try {
      setState(() => _isSubmitting = true);
      
      await ref.read(transactionServiceProvider).createTrip(
        tripName: _tripNameController.text.trim(),
        startDate: _selectedDate,
        endDate: _endDate!,
      );

      final trip = {
        'type': 'add_trip',
        'name': _tripNameController.text.trim(),
        'start_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
      };

      if (mounted) {
        setState(() {
          _createdTrips.add(trip);
          _isSubmitting = false;
        });
      }

      if (addAnother) {
        _tripNameController.clear();
        if (mounted) {
          setState(() {
            _endDate = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added! Ready for next trip')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip created')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      final appException = e is Exception ? AppException.fromError(e) : AppException.fromError(Exception(e));
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appException.getUserFriendlyMessage())),
        );
      }
    }
  }

  String _getFormTitle() {
    return switch (_transactionType) {
      'deposit' => 'Deposit Money',
      'personal_expense' => 'Add Personal Expense',
      'shared_expense' => 'Add Shared Expense',
      'add_trip' => 'Create Trip',
      _ => 'Add Transaction',
    };
  }

  IconData _getFormIcon() {
    return switch (_transactionType) {
      'deposit' => Icons.savings_outlined,
      'personal_expense' => Icons.receipt_rounded,
      'shared_expense' => Icons.group_outlined,
      'add_trip' => Icons.luggage_outlined,
      _ => Icons.add_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final poolMembersAsync = ref.watch(allPoolMembersProvider);

    if (_transactionType == 'add_trip') {
      return _buildTripForm(context, theme, poolMembersAsync);
    }

    return _buildTransactionForm(context, theme, currentUserAsync, poolMembersAsync);
  }

  Widget _buildTripForm(BuildContext context, ThemeData theme,
      AsyncValue<List<AppUser>> poolMembersAsync) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getFormTitle()),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon with gradient
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.accent.withValues(alpha: 0.15),
                      AppTheme.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getFormIcon(),
                  size: 52,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Trip Name section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Name',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _tripNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Summer Vacation',
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Start Date section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
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

            // End Date section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Date',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
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
                          _endDate != null
                              ? DateFormat('MMMM d, yyyy').format(_endDate!)
                              : 'Select end date',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _endDate == null
                                ? theme.textTheme.labelMedium?.color
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Created trips preview
            if (_createdTrips.isNotEmpty) ...[
              Text('Added Trips', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.positive.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.positive.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _createdTrips
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key < _createdTrips.length - 1 ? 8 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.positive.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.positive,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${entry.value['name']} (${DateFormat('MMM d').format(DateTime.parse(entry.value['start_date']))} → ${DateFormat('MMM d').format(DateTime.parse(entry.value['end_date']))})',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Add Another button
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitForm(addAnother: true),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Another Trip'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitForm(addAnother: false),
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
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Done',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Cancel button
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
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionForm(BuildContext context, ThemeData theme,
      AsyncValue<AppUser> currentUserAsync, AsyncValue<List<AppUser>> poolMembersAsync) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        title: Text(_getFormTitle()),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: _isSubmitting ? null : () => _submitForm(addAnother: false),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                        ),
                      )
                    : Text(
                        'Save',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Description row with icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _getFormIcon(),
                      size: 28,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter a description',
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.labelMedium?.color,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount row with $ icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '\$',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.textTheme.labelMedium?.color,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Paid by / Borrowed by / Deposited by
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_getByLabel() }  ',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildUserSelectorButton(theme, currentUserAsync, poolMembersAsync),
                ],

              ),
              const SizedBox(height: 25),

              // Date and Notes at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date selector (left)
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate.day == DateTime.now().day &&
                                  _selectedDate.month == DateTime.now().month &&
                                  _selectedDate.year == DateTime.now().year
                              ? 'Today'
                              : DateFormat('MMM d').format(_selectedDate),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notes button (right)
                  GestureDetector(
                    onTap: () => _showNotesDialog(context, theme),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 22,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Created transactions preview
              if (_createdTransactions.isNotEmpty) ...[
                Text('Added Transactions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.positive.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.positive.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _createdTransactions
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key < _createdTransactions.length - 1 ? 8 : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.positive.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.positive,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '\$${entry.value['amount']} · ${entry.value['description'] ?? '(no description)'}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Add Another button
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : () => _submitForm(addAnother: true),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Another'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes', style: theme.textTheme.titleMedium),
        content: TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Any additional notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSelectorButton(ThemeData theme, AsyncValue<AppUser> currentUserAsync, AsyncValue<List<AppUser>> poolMembersAsync) {
    return poolMembersAsync.maybeWhen(
      data: (users) {
        final options = users
            .map((u) => {'id': u.id, 'name': u.name, 'type': 'user'})
            .toList();
        
        // Only add FUNd option for shared expenses
        if (_transactionType == 'shared_expense') {
          options.add({'id': 'fund', 'name': 'FUNd', 'type': 'fund'});
        }

        return currentUserAsync.maybeWhen(
          data: (currentUser) {
            // Initialize to current user on first render (deferred via callback)
            if (_selectedUserId.isEmpty && !_isFundPool) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _selectedUserId.isEmpty) {
                  setState(() {
                    _selectedUserId = currentUser.id;
                  });
                }
              });
            }

            return PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              onSelected: (value) {
                setState(() {
                  if (value == 'fund') {
                    _isFundPool = true;
                    _selectedUserId = '';
                  } else {
                    _isFundPool = false;
                    _selectedUserId = value;
                  }
                });
              },
              itemBuilder: (BuildContext context) {
                return options.map((option) {
                  final isSelected = option['type'] == 'fund'
                      ? _isFundPool
                      : (!_isFundPool && _selectedUserId == option['id']);

                  return PopupMenuItem<String>(
                    value: option['id'] as String,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option['type'] == 'fund')
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                size: 14,
                                color: AppTheme.accent,
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
                              child: Text(
                                (option['name'] as String).isNotEmpty
                                    ? (option['name'] as String)[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            option['name'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : null,
                              color: isSelected ? AppTheme.accent : null,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppTheme.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _isFundPool ? 'FUNd' : _getSelectedUserName(users),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
          orElse: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.grey,
              ),
            ),
            child: Text('Loading...', style: theme.textTheme.bodyMedium),
          ),
        );
      },
      orElse: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey,
          ),
        ),
        child: Text('Loading...', style: theme.textTheme.bodyMedium),
      ),
    );
  }

  String _getSelectedUserName(List<AppUser> users) {
    if (_selectedUserId.isEmpty) {
      return users.isNotEmpty ? users.first.name : 'Select user';
    }
    try {
      return users.firstWhere((u) => u.id == _selectedUserId).name;
    } catch (e) {
      return _selectedUserId;
    }
  }

  String _getByLabel() {
    return switch (_transactionType) {
      'deposit' => 'Deposited By',
      'personal_expense' => 'Borrowed By',
      'shared_expense' => 'Paid By',
      _ => 'By',
    };
  }
}
