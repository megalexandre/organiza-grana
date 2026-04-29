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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final isMobile = MediaQuery.sizeOf(context).width < 800;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(Colors.black.withValues(alpha: 0.2), theme.colorScheme.surface),
        border: const Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: isMobile
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: Text(
          "Organiza Grana: $title",
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
      ),
    );
  }
}
