import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/demo_data.dart';
import '../../../core/data/transaction_repository.dart';
import '../../home/domain/finance_service.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DERIVED DATA
    final summary = FinanceService.calculate(
      allTransactions: DemoData.mockTransactions,
      selectedDate: DateTime.now(),
    );
    
    final groupedTransactions = FinanceService.groupTransactionsByMonth(DemoData.mockTransactions);

    return FutureBuilder(
      future: TransactionRepository().getPersonalGroups(),
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) return const Center(child: CircularProgressIndicator());
      
        final groupedTransactions = asyncSnapshot.data!;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: AppBar(
            title: const Text("Personal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.wb_sunny_outlined, color: Colors.black), onPressed: () {}),
              const CircleAvatar(radius: 15, backgroundColor: Color(0xFF1A1C1E), child: Text("A", style: TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 16),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTotalOwedCard(summary.userADebt + summary.userBDebt, summary.userADebt, summary.userBDebt),
              const SizedBox(height: 30),
              ...groupedTransactions.entries.map((entry) {
                String month = entry.key;
                List<Map<String, dynamic>> txs = entry.value;
                return _buildMonthSection(month, txs);
              }),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTotalOwedCard(double total, double a, double b) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance_wallet_outlined, color: Colors.red.shade400),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOTAL OWED TO POOL", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text("User A: ", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Text("\$${a.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Text("User B: ", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Text("\$${b.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(month, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionItem(tx);
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final date = DateTime.parse(tx['date']);
    final isUserA = tx['received_by'] == DemoData.userAId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A1C1E),
            child: Text(isUserA ? "A" : "B", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'] ?? 'No description', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("User ${isUserA ? 'A' : 'B'} • ${DateFormat('MMM d').format(date)}", 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Text(
            "-\$${tx['amount'].toStringAsFixed(2)}",
            style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}