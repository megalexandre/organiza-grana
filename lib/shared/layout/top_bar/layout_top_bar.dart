import 'package:flutter/material.dart';

class LayoutTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LayoutTopBar({
    super.key,
    required this.title,
    this.userEmail,
    this.userAvatarUrl,
  });

  final String title;
  final String? userEmail;
  final String? userAvatarUrl;

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
        color: Color.alphaBlend(
            Colors.black.withValues(alpha: 0.2), theme.colorScheme.surface),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
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
        centerTitle: true,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: appBarForeground,
          ),
        ),
        actions: [
          Builder(
            builder: (ctx) {
              final colorScheme = Theme.of(ctx).colorScheme;
              final initial = (userEmail?.isNotEmpty ?? false)
                  ? userEmail![0].toUpperCase()
                  : '?';
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: userAvatarUrl != null
                        ? NetworkImage(userAvatarUrl!)
                        : null,
                    child: userAvatarUrl == null
                        ? Text(
                            initial,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
