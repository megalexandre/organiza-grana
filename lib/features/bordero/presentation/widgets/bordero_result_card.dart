import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoResultCard extends StatelessWidget {
  const BorderoResultCard({
    super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final BorderoResultItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Item ${index + 1}  •  ${dateFormat.format(item.dueDate)}',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Row(
                  label: 'Valor bruto',
                  value: currencyFormat.format(item.value),
                  bold: false,
                ),
                const SizedBox(height: 8),
                _Row(
                  label: 'Dias',
                  value: '${item.totalDays}',
                  bold: false,
                ),
                const SizedBox(height: 8),
                _Row(
                  label: 'Taxa de juros',
                  value:
                      '${item.interestRatePercent.toStringAsFixed(4)}%  —  ${currencyFormat.format(item.interestAmount)}',
                  bold: false,
                ),
                const Divider(height: 24),
                _Row(
                  label: 'A receber',
                  value: currencyFormat.format(item.proceeds),
                  bold: true,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.bold,
    this.color,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodySmall),
        Text(
          value,
          style: (bold ? textTheme.bodyMedium : textTheme.bodySmall)?.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
