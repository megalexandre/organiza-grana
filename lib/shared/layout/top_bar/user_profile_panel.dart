import 'package:flutter/material.dart';
import 'package:organizagrana/shared/layout/user_display_profile.dart';
import 'package:organizagrana/shared/theme/theme_controller.dart';

class UserProfilePanel extends StatelessWidget {
  const UserProfilePanel({
    super.key,
    required this.onLogout,
    this.profile,
  });

  final Future<void> Function() onLogout;
  final UserDisplayProfile? profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeController = ThemeModeProvider.of(context);

    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            profile?.initial ?? '?',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                            ),
                          )
                        : null,
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      profile!.email,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: ValueListenableBuilder(
                valueListenable: themeController,
                builder: (_, current, _) => SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto, size: 18),
                      tooltip: 'Automático',
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 18),
                      tooltip: 'Claro',
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 18),
                      tooltip: 'Escuro',
                    ),
                  ],
                  selected: {current},
                  onSelectionChanged: (selection) =>
                      themeController.setMode(selection.first),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.logout,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              title: Text(
                'Sair',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await onLogout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
