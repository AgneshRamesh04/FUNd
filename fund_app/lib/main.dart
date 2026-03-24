import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/presentation/widgets/multi_action_fab.dart';
import 'features/personal/presentation/personal_screen.dart';
import 'features/shared/presentation/shared_screen.dart';
import 'features/shared/presentation/trip_form_screen.dart';
import 'features/transactions/domain/transaction_model.dart';
import 'features/transactions/presentation/transaction_form_screen.dart' hide TransactionType;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize services with the client
  SupabaseService().initialize(Supabase.instance.client);
  AuthService().initialize(Supabase.instance.client);

  runApp(const FUNdApp());
}

class FUNdApp extends StatelessWidget {
  const FUNdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUNd',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Using a font that mimics your clean UI mock-up
        fontFamily: 'Inter', 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1C1E),
          primary: const Color(0xFF1A1C1E),
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

/// This wrapper will eventually handle the BottomNavigationBar logic
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  // List of screens for the BottomNav
  final List<Widget> _screens = [
    HomeScreen(),
    const PersonalScreen(),
    const SharedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Personal'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Shared'),
        ],
      ),
      floatingActionButton: MultiActionFab(
        currentTabIndex: _currentIndex,
        onAddShared: () => _openForm(context, TransactionType.sharedExpense),
        onAddPersonal: () => _openForm(context, TransactionType.borrow),
        onAddDeposit: () => _openForm(context, TransactionType.deposit),
        onAddTrip: () => _openTripForm(context),
      ),
    );
  }


  void _openForm(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionFormScreen(initialType: type)),
    );
  }

  // New Trip Navigation
  void _openTripForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TripFormScreen()),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Refresh current screen to show new trip
      }
    });
  }
}
