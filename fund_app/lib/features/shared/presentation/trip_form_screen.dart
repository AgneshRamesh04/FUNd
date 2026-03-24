import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/transaction_repository.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _nameController = TextEditingController();
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create New Trip", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTrip,
            child: const Text("Create", 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Trip Icon Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.flight_takeoff, color: Colors.green, size: 32),
            ),
            const SizedBox(height: 40),
            
            // Trip Name Input
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Where are we going?",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Date Range Picker Trigger
            GestureDetector(
              onTap: _showRangePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _selectedRange == null 
                        ? "Select Dates" 
                        : "${DateFormat('MMM d').format(_selectedRange!.start)} — ${DateFormat('MMM d').format(_selectedRange!.end)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedRange = picked);
  }

  void _saveTrip() {
    if (_nameController.text.isEmpty || _selectedRange == null) return;

    final newTrip = {
      'id': 'trip-${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameController.text,
      'start_date': _selectedRange!.start.toIso8601String(),
      'end_date': _selectedRange!.end.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    TransactionRepository().addTrip(newTrip);
    Navigator.pop(context, true);
  }
}