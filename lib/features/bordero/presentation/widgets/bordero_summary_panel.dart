import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoSummaryPanel extends StatelessWidget {
  const BorderoSummaryPanel({
    super.key,
    required this.result,
    required this.itemCount,
  });

  final BorderoResult result;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          _Stat(
            label: 'ITENS',
            value: '$itemCount',
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          _Divider(colorScheme: colorScheme),
          _Stat(
            label: 'TOTAL BRUTO',
            value: currencyFormat.format(result.totalAmount),
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          _Divider(colorScheme: colorScheme),
          _Stat(
            label: 'DESCONTOS',
            value: '- ${currencyFormat.format(result.totalInterestAmount)}',
            valueColor: colorScheme.error,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          _Divider(colorScheme: colorScheme),
          _Stat(
            label: 'A RECEBER',
            value: currencyFormat.format(result.totalProceeds),
            valueColor: colorScheme.primary,
            bold: true,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 0.8,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: colorScheme.outlineVariant,
    );
  }
}
