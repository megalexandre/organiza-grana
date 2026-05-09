import 'package:flutter/material.dart';
import 'package:organizagrana/shared/layout/user_display_profile.dart';

class LayoutFooter extends StatelessWidget {
  const LayoutFooter({
    super.key,
    this.authorLabel = 'feito por alexandre queiroz',
    this.profile,
  });

  final String authorLabel;
  final UserDisplayProfile? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      letterSpacing: 0.4,
    );

    final bgColor = theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(authorLabel, style: subtleStyle),
              const Spacer(),
              if (profile != null) Text(profile!.email, style: subtleStyle),
            ],
          ),
        ),
      ),
    );
  }
}
