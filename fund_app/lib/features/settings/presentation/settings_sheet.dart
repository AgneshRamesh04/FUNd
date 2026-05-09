import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/ui/app_ui.dart';

void showSettings(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final currentThemeMode = ref.read(themeProvider);
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text('THEME', style: theme.textTheme.labelMedium),
            const SizedBox(height: 10),
            AppCardSurface(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  _ThemeOptionTile(
                    label: 'System',
                    icon: Icons.phone_android_rounded,
                    isSelected: currentThemeMode == ThemeMode.system,
                    onTap: () {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(ThemeMode.system);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  _ThemeOptionTile(
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                    isSelected: currentThemeMode == ThemeMode.light,
                    onTap: () {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(ThemeMode.light);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  _ThemeOptionTile(
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                    isSelected: currentThemeMode == ThemeMode.dark,
                    onTap: () {
                      ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.logout_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Logout?'),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Logout',
                              style: TextStyle(color: AppTheme.negative),
                            ),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirmed && context.mounted) {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected
            ? AppTheme.accent
            : theme.textTheme.labelMedium?.color,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppTheme.accent : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, size: 18, color: AppTheme.accent)
          : null,
      onTap: onTap,
    );
  }
}
