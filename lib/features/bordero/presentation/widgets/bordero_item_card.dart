import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoItemCard extends StatelessWidget {
  const BorderoItemCard({
    super.key,
    required this.index,
    required this.inputItem,
    required this.onRemove,
    this.resultItem,
  });

  final int index;
  final BorderoInputItem inputItem;
  final BorderoResultItem? resultItem;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = resultItem;

    return Dismissible(
      key: ObjectKey(inputItem),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      onDismissed: (_) => onRemove(),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(inputItem.dueDate),
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _WaitChip(days: inputItem.awaitingDays),
                  const Spacer(),
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${result.interestRatePercent.toStringAsFixed(2)}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remover',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Valor bruto',
                    value: currencyFormat.format(inputItem.value),
                  ),
                  if (result != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Dias',
                      value: '${result.totalDays} dias',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.trending_down,
                      label: 'Desconto',
                      value:
                          '${result.interestRatePercent.toStringAsFixed(4)}%  •  ${currencyFormat.format(result.interestAmount)}',
                      iconColor: colorScheme.error,
                      valueColor: colorScheme.error,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A receber',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currencyFormat.format(result.proceeds),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitChip extends StatelessWidget {
  const _WaitChip({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$days dia${days != 1 ? 's' : ''} espera',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: textTheme.bodySmall),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
