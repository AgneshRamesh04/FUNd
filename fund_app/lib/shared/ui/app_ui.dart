import 'package:flutter/material.dart';

class AppUi {
  static const double pageHorizontalPadding = 20;
  static const double pageTopPadding = 8;
  static const double pageBottomPadding = 100;

  static const double sectionGap = 28;
  static const double itemGap = 16;
  static const double compactGap = 12;
  static const double cardRadius = 16;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    pageHorizontalPadding,
    pageTopPadding,
    pageHorizontalPadding,
    pageBottomPadding,
  );
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class AppCardSurface extends StatelessWidget {
  const AppCardSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: child,
    );
  }
}

