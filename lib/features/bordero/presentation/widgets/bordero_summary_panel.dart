import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoSummaryPanel extends StatelessWidget {
  const BorderoSummaryPanel({super.key, required this.result});

  final BorderoResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total bruto',
            value: currencyFormat.format(result.totalAmount),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Total juros',
            value: currencyFormat.format(result.totalInterestAmount),
            valueColor: colorScheme.error,
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total líquido',
            value: currencyFormat.format(result.totalProceeds),
            bold: true,
            valueColor: colorScheme.primary,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Média de dias',
            value: result.averageDays.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveColor =
        valueColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
              : textTheme.bodySmall,
        ),
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
