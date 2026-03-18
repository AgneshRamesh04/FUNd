import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/transaction_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

/// Add/Edit Transaction Screen
class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late String _paidBy;
  late String _receivedBy;
  late SplitType _splitType;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction?.description ?? '');
    _amountController =
        TextEditingController(text: widget.transaction?.amount.toString() ?? '');
    _notesController =
        TextEditingController(text: widget.transaction?.notes ?? '');

    _selectedType = widget.transaction?.type ?? TransactionType.borrow;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _paidBy = widget.transaction?.paidBy ?? '';
    _receivedBy = widget.transaction?.receivedBy ?? '';
    _splitType = widget.transaction?.splitType ?? SplitType.equal;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? AppStrings.txnFormAdd
              : AppStrings.txnFormEdit,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction Type Selection
            _buildTransactionTypeSection(),
            const SizedBox(height: AppTheme.spacingL),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.txnDescription,
                hintText: 'e.g., Dinner, Gas, Movie',
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppStrings.txnAmount,
                hintText: '0.00',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Date Picker
            _buildDatePicker(context),
            const SizedBox(height: AppTheme.spacingL),

            // Paid By / Received By Fields
            _buildPaymentFields(),
            const SizedBox(height: AppTheme.spacingL),

            // Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppStrings.txnNotes,
                hintText: 'Optional notes...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              child: Text(AppStrings.btnSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.txnType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingM,
          children: TransactionType.values.map((type) {
            return ChoiceChip(
              label: Text(_getTransactionTypeLabel(type)),
              selected: _selectedType == type,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          setState(() {
            _selectedDate = selected;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.txnDate,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedDate.toString().split(' ')[0]),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedType != TransactionType.poolExpense) ...[
          Text(
            AppStrings.txnPaidBy,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppTheme.spacingS),
          DropdownButtonFormField<String>(
            value: _paidBy.isEmpty ? null : _paidBy,
            items: ['User A', 'User B', AppConstants.poolEntityName]
                .map((user) => DropdownMenuItem(
                      value: user,
                      child: Text(user),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _paidBy = value;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Select who paid',
            ),
          ),
        ],
      ],
    );
  }

  void _saveTransaction() {
    // Validate inputs
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errEmptyDescription)),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errInvalidAmount)),
      );
      return;
    }

    try {
      final amount = double.parse(_amountController.text);

      if (amount <= 0) {
        throw FormatException();
      }

      final now = DateTime.now();
      final transaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        type: _selectedType,
        description: _descriptionController.text,
        amount: amount,
        paidBy: _paidBy,
        receivedBy: _receivedBy,
        splitType: _splitType,
        date: _selectedDate,
        notes: _notesController.text,
        createdAt: widget.transaction?.createdAt ?? now,
        updatedAt: now,
      );

      // Validate transaction
      final validationError = TransactionService.validateTransaction(transaction);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.successAdded),
        ),
      );

      Navigator.of(context).pop(transaction);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errInvalidAmount)),
      );
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.borrow:
        return AppStrings.txnTypeBorrow;
      case TransactionType.deposit:
        return AppStrings.txnTypeDeposit;
      case TransactionType.sharedExpense:
        return AppStrings.txnTypeSharedExpense;
      case TransactionType.poolExpense:
        return AppStrings.txnTypePoolExpense;
    }
  }
}
