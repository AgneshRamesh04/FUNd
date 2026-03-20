import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/transaction_repository.dart';
import '../../../core/constants/demo_data.dart';
import '../domain/trip_model.dart';

class TripDetailsScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: TransactionRepository().getAllTransactions(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter: Only transactions belonging to THIS trip
          final tripTxs = snapshot.data!
              .where((tx) => tx['trip_id'] == trip.id)
              .toList();
          
          // Sort by date ascending to show the trip timeline
          tripTxs.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTripSummaryHeader(),
              const SizedBox(height: 30),
              const Text("EXPENSE LOG", 
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              if (tripTxs.isEmpty) 
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("No expenses recorded for this trip."),
                ))
              else
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: List.generate(tripTxs.length, (index) {
                      final tx = tripTxs[index];
                      return Column(
                        children: [
                          _buildTripTransactionItem(tx),
                          if (index != tripTxs.length - 1) const Divider(height: 1, indent: 70),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1C1E), Color(0xFF373A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL TRIP COST", 
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text("\$${NumberFormat("#,###.00").format(trip.totalCost)}", 
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white60, size: 14),
              const SizedBox(width: 8),
              Text(
                "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d').format(trip.endDate)}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTransactionItem(Map<String, dynamic> tx) {
    final isA = tx['paid_by'] == DemoData.userAId;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF1F3F5),
            child: Text(isA ? "A" : "B", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'] ?? 'Expense', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(DateFormat('MMM d, h:mm a').format(DateTime.parse(tx['date'])), 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text("\$${tx['amount'].toStringAsFixed(2)}", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}