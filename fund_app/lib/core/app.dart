import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/transactions/presentation/transaction_form_page.dart';
import '../features/shell/shell_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/transaction-form':
        final args = settings.arguments as TransactionFormArgs?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Missing arguments'))),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TransactionFormPage(args: args),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AuthGate(),
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
