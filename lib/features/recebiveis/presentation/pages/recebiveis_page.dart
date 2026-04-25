import 'package:flutter/material.dart';

class RecebiveisPage extends StatelessWidget {
  const RecebiveisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recebíveis',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Acompanhe os valores previstos e recebidos em um único lugar.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}
