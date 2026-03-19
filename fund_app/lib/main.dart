import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/theme/app_theme.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/features/home/screens/home_screen.dart';
import 'package:fund_app/features/personal/screens/personal_screen.dart';
import 'package:fund_app/features/shared/screens/shared_screen.dart';
import 'package:fund_app/features/transactions/screens/add_transaction_screen.dart';

void main() async {
  // Initialize Supabase
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUNd',
      theme: AppTheme.lightTheme(),
      home: const HomeNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  bool _fabExpanded = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PersonalScreen(),
    const SharedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionModal() {
    setState(() {
      _fabExpanded = false;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      builder: (context) => const AddTransactionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          // FAB Menu Overlay
          if (_fabExpanded)
            GestureDetector(
              onTap: () {
                setState(() {
                  _fabExpanded = false;
                });
              },
              child: Container(color: Colors.black.withAlpha(102)),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Shared',
          ),
        ],
      ),
      floatingActionButton: _fabExpanded
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFabOption(
                  icon: Icons.download,
                  label: 'Deposit',
                  onTap: _showAddTransactionModal,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _buildFabOption(
                  icon: Icons.shopping_cart,
                  label: 'Shared Expense',
                  onTap: _showAddTransactionModal,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _buildFabOption(
                  icon: Icons.calendar_today,
                  label: 'Personal Expense',
                  onTap: _showAddTransactionModal,
                ),
                const SizedBox(height: AppTheme.spacing12),
                FloatingActionButton(
                  heroTag: 'close_fab',
                  onPressed: () {
                    setState(() {
                      _fabExpanded = false;
                    });
                  },
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.close),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'main_fab',
              onPressed: () {
                setState(() {
                  _fabExpanded = true;
                });
              },
              tooltip: 'Add Transaction',
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
