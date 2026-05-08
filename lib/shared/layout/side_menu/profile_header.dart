import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.userEmail, this.userAvatarUrl});

  final String? userEmail;
  final String? userAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = (userEmail?.isNotEmpty ?? false)
        ? userEmail![0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(

        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
            child: userAvatarUrl != null
                ? null
                : Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          if (userEmail != null)
            Text(
              userEmail!,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
