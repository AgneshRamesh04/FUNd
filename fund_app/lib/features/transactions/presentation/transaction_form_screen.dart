import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/transaction_repository.dart';
import '../../../core/models/transaction_model.dart' as core_models;
import '../../../core/services/auth_service.dart';
import '../domain/transaction_model.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionType initialType;
  final String? tripId;

  const TransactionFormScreen({super.key, required this.initialType, this.tripId});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    String title = "Add Shared Expense";
    if (widget.initialType == TransactionType.borrow) title = "Add Personal Expense";
    if (widget.initialType == TransactionType.deposit) title = "Add Deposit";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Save", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Icon Header based on type
            _buildTypeIcon(),
            const SizedBox(height: 30),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: "Description", border: InputBorder.none),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text("\$", style: TextStyle(fontSize: 24, color: Colors.grey)),
                IntrinsicWidth(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: "0.00", border: InputBorder.none),
                    autofocus: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                      _buildChip("", DateFormat('MMM d').format(_selectedDate), Icons.calendar_today_outlined, _showDatePicker),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final currentUserId = authService.currentUserId;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Determine transaction type string
      String typeString = 'shared_expense';
      if (widget.initialType == TransactionType.borrow) {
        typeString = 'borrow';
      } else if (widget.initialType == TransactionType.deposit) {
        typeString = 'deposit';
      }

      // Create month_key for efficient querying
      final monthKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';

      // Create transaction model
      final newTransaction = core_models.TransactionModel(
        id: '', // Supabase will generate this
        type: typeString,
        userId: currentUserId,
        description: _descController.text.isEmpty ? 'Untitled' : _descController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _selectedDate,
        notes: null,
        tripId: widget.tripId,
        monthKey: monthKey,
      );

      // Create transaction via repository
      await TransactionRepository().createTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    Color iconColor = Colors.green;

    if (widget.initialType == TransactionType.borrow) {
      icon = Icons.account_balance_wallet;
      color = Colors.red.shade50;
      iconColor = Colors.red.shade400;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: iconColor, size: 32),
    );
  }

  Widget _buildChip(String prefix, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: const Color(0xFFF8F9FB),
      label: Row(
        children: [
          if (prefix.isNotEmpty) Text(prefix, style: const TextStyle(color: Colors.grey)),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Icon(icon, size: 14),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}