import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoItemTile extends StatelessWidget {
  const BorderoItemTile({
    super.key,
    required this.item,
    required this.onRemove,
  });

  final BorderoInputItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  currencyFormat.format(item.value),
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  dateFormat.format(item.dueDate),
                  style: textTheme.bodyMedium,
                ),
                Text(
                  '${item.awaitingDays} dia${item.awaitingDays != 1 ? 's' : ''} em espera',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: colorScheme.error),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}
