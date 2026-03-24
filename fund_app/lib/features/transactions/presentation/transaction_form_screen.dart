import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/demo_data.dart';
import '../../../core/data/transaction_repository.dart';
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
  final String _selectedUser = DemoData.userAId;
  DateTime _selectedDate = DateTime.now();

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
            onPressed: () {
                if (_amountController.text.isEmpty) return;

                final newTx = {
                    'id': DateTime.now().toString(),
                    'type': widget.initialType == TransactionType.sharedExpense ? 'shared_expense' : 'borrow',
                    'description': _descController.text.isEmpty ? 'Untitled' : _descController.text,
                    'amount': double.tryParse(_amountController.text) ?? 0.0,
                    'paid_by': _selectedUser,
                    'received_by': widget.initialType == TransactionType.sharedExpense ? 'shared' : _selectedUser,
                    'date': _selectedDate.toIso8601String(),
                    'trip_id': widget.tripId, // Passed if adding from a trip page
                };

                TransactionRepository().addTransaction(newTx);
                Navigator.pop(context, true); // Return true to indicate success
            },
            child: const Text("Save", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
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
                _buildChip("By ", _selectedUser == DemoData.userAId ? "User A" : "User B", Icons.person_outline, _showUserPicker),
                const SizedBox(width: 12),
                _buildChip("", DateFormat('MMM d').format(_selectedDate), Icons.calendar_today_outlined, _showDatePicker),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon = Icons.shopping_cart;
    Color color = Colors.green.shade50;
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

  void _showUserPicker() { /* Implement simple bottom sheet for A/B */ }
  void _showDatePicker() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2025), lastDate: DateTime(2027));
    if (picked != null) setState(() => _selectedDate = picked);
  }
}