import 'package:flutter/material.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/personal/presentation/personal_screen.dart';
import 'features/shared/presentation/shared_screen.dart';

void main() {
  // In the future, we will initialize Supabase here:
  // await Supabase.initialize(url: ..., anonKey: ...);
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
    );
  }
}