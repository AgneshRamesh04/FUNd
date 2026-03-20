import 'package:flutter/material.dart';
import 'package:fund_app/features/shared/presentation/trip_details_screen.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/demo_data.dart';
import '../../../core/data/transaction_repository.dart';
import '../../home/domain/finance_service.dart';
import '../domain/trip_model.dart';

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  bool _isTripsExpanded = false;
  // 1. Initialize with the current month/year
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month);
  }

  // Helper to generate the dropdown months (same as Home)
  List<DateTime> _getRecentMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) => DateTime(now.year, now.month - i));
  }

  @override
  Widget build(BuildContext context) {
    final String monthDisplay = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // 2. Month Selector in Top Left
        title: GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthDisplay,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
      body: FutureBuilder(
        future: Future.wait([
          TransactionRepository().getAllTransactions(),
          TransactionRepository().getAllTrips(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          final List<Map<String, dynamic>> allTxs = snapshot.data![0];
          final List<Map<String, dynamic>> allTripsRaw = snapshot.data![1];

          // 3. Calculate Monthly Summary based on _selectedDate
          final sharedTotal = FinanceService.calculateSharedTotal(allTxs, _selectedDate);

          // 4. Trips Logic (Trips stay visible regardless of month, but costs are lifetime)
          final List<TripModel> trips = allTripsRaw.map((t) {
            final tripCost = allTxs
                .where((tx) => tx['trip_id'] == t['id'])
                .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
            return TripModel.fromMap(t, tripCost);
          }).toList();
          trips.sort((a, b) => b.startDate.compareTo(a.startDate));

          final displayedTrips = _isTripsExpanded ? trips : (trips.isNotEmpty ? [trips.first] : <TripModel>[]);

          // 5. Grouped transactions filtered by selected month
          final groupedTxs = FinanceService.groupSharedByMonth(allTxs);
          final String currentKey = DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase();
          final currentMonthTxs = groupedTxs[currentKey] ?? [];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              _buildSharedSummaryCard(sharedTotal),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TRIPS", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  if (trips.length > 1)
                    GestureDetector(
                      onTap: () => setState(() => _isTripsExpanded = !_isTripsExpanded),
                      child: Text(_isTripsExpanded ? "SHOW LESS" : "SHOW ALL", 
                        style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...displayedTrips.map((trip) => _buildTripCard(context, trip)),
              
              const SizedBox(height: 30),
              
              // Only show transactions for the selected month
              _buildMonthSection(currentKey, currentMonthTxs),
            ],
          );
        },
      ),
    );
  }

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
                trailing: date.month == _selectedDate.month && date.year == _selectedDate.year 
                  ? const Icon(Icons.check, color: Colors.green) : null,
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

  Widget _buildSharedSummaryCard(double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SHARED THIS MONTH", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final range = "${DateFormat('MMM d').format(trip.startDate)} — ${DateFormat('MMM d').format(trip.endDate)}";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell( // Make it clickable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(trip: trip),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.flight_takeoff, color: Colors.green, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(range, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ]
                ),
              ),
              Text("\$${NumberFormat("#,###").format(trip.totalCost)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Map<String, dynamic>> txs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(month, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: List.generate(txs.length, (index) {
              final tx = txs[index];
              return Column(
                children: [
                  _buildSharedItem(tx),
                  if (index != txs.length - 1) const Divider(height: 1, indent: 70),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSharedItem(Map<String, dynamic> tx) {
    final isA = tx['paid_by'] == DemoData.userAId;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A1C1E),
            child: Text(isA ? "A" : "B", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'] ?? 'Shared Expense', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Paid by User ${isA ? 'A' : 'B'} • ${DateFormat('MMM d').format(DateTime.parse(tx['date']))}", 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Text("\$${tx['amount'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}