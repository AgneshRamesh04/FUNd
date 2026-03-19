import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to your pubspec.yaml
import '../../../core/constants/demo_data.dart';
import '../domain/finance_service.dart';
import '../../leave/domain/leave_model.dart';
import '../domain/finance_summary.dart';
import 'widgets/home_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Dynamically set to the first day of the current month/year
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month);
  }

  // Helper to create the dropdown items (current month + last 5 months)
  List<DateTime> _getRecentMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) => DateTime(now.year, now.month - i));
  }

  @override
  Widget build(BuildContext context) {
    // 2. Derive all data based on the dynamic _selectedDate
    final summary = FinanceService.calculate(
      allTransactions: DemoData.mockTransactions,
      selectedDate: _selectedDate,
    );

    final leaveModels = DemoData.mockLeaveTable
        .map((map) => LeaveModel.fromMap(map))
        .toList();

    // Format for the AppBar title
    final String monthDisplay = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthDisplay,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.wb_sunny_outlined, color: Colors.black), onPressed: () {}),
          const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFF1A1C1E),
              child: Text("A", style: TextStyle(color: Colors.white, fontSize: 12))
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("POOL BALANCE",
                style: TextStyle(color: Colors.grey, letterSpacing: 1.5, fontSize: 10, fontWeight: FontWeight.bold)),
            Text("\$${summary.poolBalance.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),

            Row(
              children: [
                _buildStatCard("INFLOW", "+\$${summary.inflow.toStringAsFixed(2)}", Colors.green, summary.inflowGraph),
                const SizedBox(width: 16),
                _buildStatCard("OUTFLOW", "-\$${summary.outflow.toStringAsFixed(2)}", Colors.red, summary.outflowGraph),
              ],
            ),

            const SizedBox(height: 20),
            _buildDebtSection(summary),
            const SizedBox(height: 20),
            _buildLeaveSection(leaveModels),
          ],
        ),
      ),
    );
  }

  // Simple selector for Stage 1.
  // In Stage 3, we can make this a more beautiful bottom sheet.
  void _showMonthPicker(BuildContext context) {
    final months = _getRecentMonths();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ...months.map((date) => ListTile(
                title: Text(DateFormat('MMMM yyyy').format(date)),
                trailing: date.month == _selectedDate.month ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setState(() => _selectedDate = date);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, List<double> chartData) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            // Dynamic Value from FinanceService
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // The MiniChart we built earlier
            MiniChart(data: chartData, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtSection(FinanceSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MONEY OWED TO POOL",
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          // Pass specific User A and B data from the summary
          _debtRow("A", "User A owes", summary.userADebt),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(color: Color(0xFFF1F1F1)),
          ),
          _debtRow("B", "User B owes", summary.userBDebt),
        ],
      ),
    );
  }

  Widget _debtRow(String initial, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Dark circular avatar from your UI
          CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1A1C1E),
              child: Text(initial, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),
          const Spacer(),
          // Formatted amount
          Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // Gray out if debt is zero to match mock-up logic
                  color: amount > 0 ? Colors.black : Colors.grey.shade400
              )
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSection(List<LeaveModel> leaveData) {
    return Row(
      children: leaveData.map((leave) {
        // Logic: If 'balance' in DB is the total allowed,
        // remaining = balance - used.
        final int remaining = leave.remaining;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${leave.userName.toUpperCase()} LEAVE",
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("${leave.used} Used / $remaining Remaining",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                // Progress bar using the 'used' and the 'total' (used + remaining)
                LeaveProgressBar(
                    used: leave.used,
                    total: leave.used + remaining
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}