import 'package:flutter/material.dart';
import 'package:organizagrana/features/auth/presentation/widgets/piggy_coin_animation.dart';

class LoginBrandContent extends StatelessWidget {
  const LoginBrandContent({
    super.key,
    required this.color,
    this.compact = false,
  });

  final Color color;
  final bool compact;

  static const _bullets = [
    'Controle de recebíveis',
    'Visão completa das finanças',
    'Relatórios e resumos',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return compact ? _buildBar(textTheme) : _buildPanel(textTheme);
  }

  Widget _buildPanel(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PiggyCoinAnimation(color: color),
          const SizedBox(height: 24),
          Text(
            'Organiza Grana',
            style: textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Organize suas finanças com clareza.',
            style: textTheme.titleMedium?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 40),
          ..._bullets.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: color.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          PiggyCoinAnimation(color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Organiza Grana',
                style: textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Organize suas finanças com clareza.',
                style: textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
