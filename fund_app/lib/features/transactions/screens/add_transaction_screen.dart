import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/theme/app_theme.dart';
import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/features/transactions/providers/add_transaction_provider.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
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
    final state = ref.watch(addTransactionProvider);
    final notifier = ref.read(addTransactionProvider.notifier);

    // Show success dialog
    if (state.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        notifier.resetSuccess();
        Navigator.pop(context);
      });
    }

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close and save buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  const Text(
                    'Add an expense',
                    style: AppTheme.titleLarge,
                  ),
                  GestureDetector(
                    onTap: () => notifier.submitTransaction(),
                    child: Text(
                      'Save',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing20),

              // With you and selector
              _buildWithYouSection(),
              const SizedBox(height: AppTheme.spacing20),

              // Description with icon
              _buildDescriptionWithIcon(notifier, _descriptionController),
              const SizedBox(height: AppTheme.spacing20),

              // Amount field
              _buildAmountField(notifier, _amountController),
              const SizedBox(height: AppTheme.spacing12),

              // Split info
              Text(
                'Paid by you and split equally',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacing20),

              // Date and split type selection
              _buildDateAndSplitSection(notifier, state),
              const SizedBox(height: AppTheme.spacing24),

              // Paid by field
              _buildPaidByField(notifier, state),
              const SizedBox(height: AppTheme.spacing16),

              // Notes field
              _buildNotesField(notifier, _notesController),
              const SizedBox(height: AppTheme.spacing16),

              _buildErrorMessage(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithYouSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            child: Text('A', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            'All of tuscany trip',
            style: AppTheme.bodySmall,
          ),
          const Spacer(),
          const Text('❤️', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNotesField(
    AddTransactionNotifier notifier,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes (Optional)', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: AppTheme.spacing8),
        TextField(
          controller: controller,
          onChanged: notifier.setNotes,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add any additional details...',
            hintStyle: AppTheme.bodySmall,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(AddTransactionState state) {
    if (state.error == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.errorColor),
      ),
      child: Text(
        state.error!,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
      ),
    );
  }

  Widget _buildDescriptionWithIcon(
    AddTransactionNotifier notifier,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8D5C4),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: const Icon(Icons.directions_car, size: 20),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: notifier.setDescription,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Description',
              hintStyle: AppTheme.bodyMedium,
            ),
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSection(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacing12),
        Wrap(
          spacing: AppTheme.spacing12,
          runSpacing: AppTheme.spacing12,
          children: [
            _buildTypeChip(
              label: 'Borrow',
              isSelected: state.selectedType == TransactionType.borrow,
              onTap: () => notifier.setTransactionType(TransactionType.borrow),
            ),
            _buildTypeChip(
              label: 'Deposit',
              isSelected: state.selectedType == TransactionType.deposit,
              onTap: () => notifier.setTransactionType(TransactionType.deposit),
            ),
            _buildTypeChip(
              label: 'Shared Expense',
              isSelected: state.selectedType == TransactionType.sharedExpense,
              onTap: () =>
                  notifier.setTransactionType(TransactionType.sharedExpense),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateAndSplitSection(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDateChip('Today'),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildDateChip('Tuscany trip 🎫'),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                notifier.setDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing12,
                vertical: AppTheme.spacing12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.calendar_today, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppTheme.backgroundColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildAmountField(
    AddTransactionNotifier notifier,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$',
              style: AppTheme.headlineLarge.copyWith(
                fontSize: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  final amount = double.tryParse(value) ?? 0;
                  notifier.setAmount(amount);
                },
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTheme.headlineMedium.copyWith(
                  fontSize: 32,
                  color: AppTheme.primaryColor,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Container(
          height: 2,
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildPaidByField(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paid By', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: AppTheme.spacing8),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
          ),
          child: DropdownButton<String>(
            value: state.paidBy,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Select user', style: AppTheme.bodyMedium),
            items: ['User A', 'User B']
                .map((user) => DropdownMenuItem(
                      value: user,
                      child: Text(user, style: AppTheme.bodyMedium),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) notifier.setPaidBy(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedByField(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return SizedBox.shrink();
  }

  Widget _buildSplitTypeField(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return SizedBox.shrink();
  }

  Widget _buildDateField(
    AddTransactionNotifier notifier,
    AddTransactionState state,
  ) {
    return SizedBox.shrink();

  Widget _buildNotesField(
    AddTransactionNotifier notifier,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes (Optional)', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: AppTheme.spacing8),
        TextField(
          controller: controller,
          onChanged: notifier.setNotes,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add any additional details...',
            hintStyle: AppTheme.bodySmall,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(AddTransactionState state) {
    if (state.error == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.errorColor),
      ),
      child: Text(
        state.error!,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
      ),
    );
  }
}
}
