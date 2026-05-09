import 'package:flutter/material.dart';

class UserProfilePanel extends StatelessWidget {
  const UserProfilePanel({
    super.key,
    required this.onLogout,
    required this.userEmail,
    this.userAvatarUrl,
  });

  final Future<void> Function() onLogout;
  final String userEmail;
  final String? userAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = userEmail;

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
              child: Column(
                children: [
                  CircleAvatar(
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
                              fontSize: 32,
                            ),
                          )
                        : null,
                  ),
                    const SizedBox(height: 14),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
              ),
            ),
            const Divider(height: 1),
            const Spacer(),
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
