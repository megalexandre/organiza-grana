import 'package:flutter/material.dart';

class LayoutTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LayoutTopBar({
    super.key,
    required this.title,
    required this.onLogout,
    this.logoutTooltip = 'Sair',
  });

  final String title;
  final Future<void> Function() onLogout;
  final String logoutTooltip;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final shadowColor = theme.colorScheme.shadow.withValues(alpha: 0.12);
    final dividerColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.9);

    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: dividerColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const SizedBox(height: 2),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: appBarForeground,
        ),
      ),
      actions: [
        IconButton(
          tooltip: logoutTooltip,
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
