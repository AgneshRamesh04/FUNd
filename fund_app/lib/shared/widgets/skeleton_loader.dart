import 'package:flutter/material.dart';

/// Skeleton loader for card placeholders during data loading
class CardSkeleton extends StatefulWidget {
  const CardSkeleton({super.key});

  @override
  State<CardSkeleton> createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<CardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: theme.dividerTheme.color ?? Colors.grey[400],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              height: 24,
              width: 150,
              decoration: BoxDecoration(
                color: theme.dividerTheme.color ?? Colors.grey[400],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for transaction list
class TransactionListSkeleton extends StatefulWidget {
  final int itemCount;

  const TransactionListSkeleton({super.key, this.itemCount = 3});

  @override
  State<TransactionListSkeleton> createState() =>
      _TransactionListSkeletonState();
}

class _TransactionListSkeletonState extends State<TransactionListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _animation,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.transparent,
          ),
        ),
        child: Column(
          children: List.generate(
            widget.itemCount,
            (i) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: theme.dividerTheme.color ?? Colors.grey[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: theme.dividerTheme.color ?? Colors.grey[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  if (i < widget.itemCount - 1) ...[
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.dividerTheme.color,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
