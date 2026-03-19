import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/theme/app_theme.dart';
import 'package:fund_app/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: GestureDetector(
            onTap: () {
              // TODO: Open month/year picker
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Center(
                child: Text(
                  'March 2026',
                  style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing12),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor,
              child: const Text(
                'A',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).refreshData(),
        child: homeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : homeState.error != null
                ? Center(
                    child: Text(
                      'Error: ${homeState.error}',
                      style: AppTheme.bodyMedium,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pool Balance Card
                        _buildPoolBalanceCard(homeState.poolBalance),
                        const SizedBox(height: AppTheme.spacing20),

                        // Inflow/Outflow Cards
                        _buildFlowCardsSection(homeState.monthlySummary),
                        const SizedBox(height: AppTheme.spacing20),

                        // Money Owed to Pool
                        _buildMoneyOwedSection(homeState.userDebts),
                        const SizedBox(height: AppTheme.spacing20),

                        // Leave Tracking
                        _buildLeaveTrackingSection(),
                        const SizedBox(height: AppTheme.spacing32),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPoolBalanceCard(double poolBalance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'POOL BALANCE',
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          '\$${poolBalance.toStringAsFixed(2)}',
          style: AppTheme.headlineLarge.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFlowCardsSection(Map<String, dynamic> monthlySummary) {
    final inflow = monthlySummary['user1']?['inflow'] ?? 0.0;
    final outflow = monthlySummary['user1']?['outflow'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildFlowCard(
            title: 'INFLOW',
            amount: inflow,
            color: AppTheme.successColor,
            isInflow: true,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildFlowCard(
            title: 'OUTFLOW',
            amount: outflow,
            color: AppTheme.errorColor,
            isInflow: false,
          ),
        ),
      ],
    );
  }

  Widget _buildFlowCard({
    required String title,
    required double amount,
    required Color color,
    required bool isInflow,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '${isInflow ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: AppTheme.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          // Simple bar chart placeholder
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                8,
                (index) => Container(
                  width: 4,
                  height: 15 + (index * 5).toDouble(),
                  decoration: BoxDecoration(
                    color: color.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyOwedSection(Map<String, double> userDebts) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONEY OWED TO POOL',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          ...userDebts.entries.map((entry) {
            final isPositive = entry.value > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Text(
                        entry.key,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: AppTheme.titleMedium.copyWith(
                      color: isPositive ? AppTheme.errorColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLeaveTrackingSection() {
    // TODO: Fetch actual leave data from the database
    return Row(
      children: [
        Expanded(
          child: _buildLeaveCard(
            title: 'USER A LEAVE',
            used: 2,
            remaining: 6,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildLeaveCard(
            title: 'USER B LEAVE',
            used: 1,
            remaining: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveCard({
    required String title,
    required int used,
    required int remaining,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '$used Used / $remaining Remaining',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacing12),
          // Leave indicator dots
          Row(
            children: [
              ...List.generate(
                used,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              ...List.generate(
                remaining,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
