import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/ui/app_feedback.dart';
import '../../../shared/ui/app_ui.dart';
import '../data/leave_providers.dart';

class ManageLeaveTotalsPage extends ConsumerStatefulWidget {
  final String userId;
  final int year;

  const ManageLeaveTotalsPage({
    super.key,
    required this.userId,
    required this.year,
  });

  @override
  ConsumerState<ManageLeaveTotalsPage> createState() =>
      _ManageLeaveTotalsPageState();
}

class _ManageLeaveTotalsPageState extends ConsumerState<ManageLeaveTotalsPage> {
  late TextEditingController _totalController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController();
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final total = int.tryParse(_totalController.text);
    if (total == null || total < 0) {
      _showError('Please enter a valid total');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(leaveTrackingMutationProvider.notifier)
          .updateTotal(
            userId: widget.userId,
            year: widget.year,
            total: total,
          );

      if (mounted) {
        // Invalidate and refetch the provider
        ref.invalidate(leaveTrackingProvider((widget.userId, widget.year)));

        AppFeedback.showSuccess(context, 'Leave total updated successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('Failed to update: $e');
      }
    }
  }

  void _showError(String message) {
    AppFeedback.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leaveTrackingAsync = ref.watch(
      leaveTrackingProvider((widget.userId, widget.year)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leave Totals'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: Text(
              'Save',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppUi.pagePadding,
        child: leaveTrackingAsync.maybeWhen(
          data: (tracking) {
            if (tracking == null) {
              return Center(
                child: Text('Loading...', style: theme.textTheme.bodyLarge),
              );
            }

            // Initialize controller with current value
            if (_totalController.text.isEmpty) {
              _totalController.text = tracking.total.toString();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Year Info
                AppCardSurface(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year ${widget.year}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.labelMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  'Used',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.labelMedium?.color,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${tracking.used} days',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.labelMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tracking.remaining} days',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tracking.remaining > 0
                                      ? AppTheme.positive
                                      : AppTheme.negative,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppUi.sectionGap),

                // Total Leave Input
                AppCardSurface(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Leave Days',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _totalController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      decoration: InputDecoration(
                        hintText: '20',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppTheme.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set the total number of leave days available for ${widget.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.labelMedium?.color,
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: AppUi.sectionGap),

                // Info Box
                AppCardSurface(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            size: 20,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Changing the total will update leave balance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The total leave days define how many days you can take off in ${widget.year}. Days used are tracked automatically when you add leave entries.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppUi.sectionGap),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Update Total',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
