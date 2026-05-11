import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/leave/presentation/leave_page.dart';
import '../features/transactions/presentation/transaction_form_page.dart';
import '../features/shell/shell_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  DateTime _parseDateOrNow(String? value) {
    if (value == null || value.trim().isEmpty) return DateTime.now();
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return DateTime.now();
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String _routePathFromUri(Uri uri) {
    String normalized(String value) =>
        value.startsWith('/') ? value : '/$value';

    if (uri.path.isNotEmpty) return normalized(uri.path);
    if (uri.host.isNotEmpty) return normalized(uri.host);
    return '/';
  }

  Route<dynamic> _missingArgumentsRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final rawRoute = settings.name ?? '/';
    final uri = Uri.tryParse(rawRoute);
    final routePath = uri == null
        ? (rawRoute.startsWith('/') ? rawRoute : '/$rawRoute')
        : _routePathFromUri(uri);
    final query = uri?.queryParameters ?? const <String, String>{};

    // iOS may deliver custom-scheme links like fund://transaction-form?... as
    // '/?...' (host gets dropped from route name). Infer route from known params.
    final effectiveRoutePath =
        routePath == '/' && query.containsKey('type')
            ? '/transaction-form'
            : routePath == '/' && query.containsKey('userId')
            ? '/leave'
            : routePath;

    debugPrint(
      'Deep link route received | raw: $rawRoute | uri: ${uri?.toString() ?? 'null'} | path: $routePath | effectivePath: $effectiveRoutePath',
    );

    switch (effectiveRoutePath) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case '/transaction-form':
        final argsFromNavigation = settings.arguments as TransactionFormArgs?;
        if (argsFromNavigation != null) {
          return MaterialPageRoute(
            builder: (_) => TransactionFormPage(args: argsFromNavigation),
          );
        }

        final type = _normalizeTransactionType(query['type']);
        if (type == null || type.isEmpty) {
          return _missingArgumentsRoute(
            'Missing required URL parameter: type',
          );
        }

        final args = TransactionFormArgs(
          type: type,
          initialMonth: _parseDateOrNow(query['date']),
          initialDescription: query['description']?.trim(),
          initialAmount: _parseAmountOrZero(query['amount']),
          initialUserName: query['user']?.trim(),
          isDeepLink: true,
          confirmOnOpen: _parseBool(query['confirm']),
          tripId: query['tripId']?.trim().isEmpty == true
              ? null
              : query['tripId']?.trim(),
          tripName: query['tripName']?.trim().isEmpty == true
              ? null
              : query['tripName']?.trim(),
        );
        return MaterialPageRoute(builder: (_) => TransactionFormPage(args: args));
      case '/leave':
        final userId = uri?.queryParameters['userId']?.trim();
        return MaterialPageRoute(
          builder: (_) => LeavePage(
            initialUserId: (userId == null || userId.isEmpty) ? null : userId,
          ),
          fullscreenDialog: true,
        );
      default:
        return _missingArgumentsRoute('Unknown route: $rawRoute');
    }
  }

  String? _normalizeTransactionType(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase().replaceAll('-', '_');
    if (normalized == 'borrow') return 'personal_expense';
    return normalized;
  }

  double _parseAmountOrZero(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value.trim()) ?? 0;
  }

  bool _parseBool(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
