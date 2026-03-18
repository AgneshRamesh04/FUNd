import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/transaction_providers.dart';

/// Add/Edit Transaction Screen - Clean Architecture Version
class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;

  const AddTransactionScreen({
    Key? key,
    this.transactionId,
  }) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late String _selectedType;
  late DateTime _selectedDate;
  late String _paidBy;
  late String _receivedBy;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    _selectedType = 'borrow';
    _selectedDate = DateTime.now();
    _paidBy = '';
    _receivedBy = '';
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
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTransactionTypeSection(),
            const SizedBox(height: AppTheme.spacingL),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.txnDescription,
                hintText: 'e.g., Dinner, Gas, Movie',
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
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
            _buildDatePicker(context),
            const SizedBox(height: AppTheme.spacingL),
            _buildPaymentFields(),
            const SizedBox(height: AppTheme.spacingL),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppStrings.txnNotes,
                hintText: 'Optional notes...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton(
              onPressed: _handleSave,
              child: const Text(AppStrings.btnSave),
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
          children: ['borrow', 'deposit', 'shared_expense', 'pool_expense']
              .map((type) {
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
    );
  }

  void _handleSave() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errEmptyDescription)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.successAdded)),
    );

    Navigator.of(context).pop();
  }

  String _getTransactionTypeLabel(String type) {
    switch (type) {
      case 'borrow':
        return AppStrings.txnTypeBorrow;
      case 'deposit':
        return AppStrings.txnTypeDeposit;
      case 'shared_expense':
        return AppStrings.txnTypeSharedExpense;
      case 'pool_expense':
        return AppStrings.txnTypePoolExpense;
      default:
        return type;
    }
  }
}
