import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/constants/app_constants.dart';

/// Personal Screen - Borrow transactions
class PersonalScreen extends ConsumerWidget {
  const PersonalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.personalTitle),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please sign in'),
            );
          }
          return _buildPersonalContent(context, ref, user.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildPersonalContent(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final userBorrows = ref.watch(userBorrowsProvider(userId));

    return userBorrows.when(
      data: (borrows) {
        if (borrows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 64,
                  color: AppTheme.textColorTertiary,
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  AppStrings.noBorrows,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textColorTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          itemCount: borrows.length,
          itemBuilder: (context, index) {
            final transaction = borrows[index];
            return _buildBorrowCard(context, transaction);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildBorrowCard(
    BuildContext context,
    Transaction transaction,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        transaction.date.toString().split(' ')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.errorDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacingM),
                child: Text(
                  transaction.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textColorSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
