import 'package:flutter/material.dart';

class LayoutFooter extends StatelessWidget {
  const LayoutFooter({
    super.key,
    this.authorLabel = 'feito por alexandre queiroz',
    this.userEmail,
  });

  final String authorLabel;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      letterSpacing: 0.4,
    );

    return ColoredBox(
      color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(authorLabel, style: subtleStyle),
              const Spacer(),
              if (userEmail != null) Text(userEmail!, style: subtleStyle),
            ],
          ),
        ),
      ),
    );
  }
}
