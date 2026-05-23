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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      onDismissed: (_) => onRemove(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.brightness == Brightness.dark
              ? Color.alphaBlend(Colors.white.withValues(alpha: 0.07), colorScheme.surface)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — número, data, chips
                Row(
                  children: [
                    Text(
                      'Nº ${(index + 1).toString().padLeft(3, '0')}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(inputItem.dueDate),
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _WaitChip(days: inputItem.awaitingDays),
                    const Spacer(),
                    if (result != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
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
                    ],
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Remover',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DashedDivider(color: colorScheme.outline),
                const SizedBox(height: 12),
                // Corpo
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
                  const SizedBox(height: 14),
                  _DashedDivider(color: colorScheme.outline),
                  const SizedBox(height: 12),
                  // Rodapé — A receber
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A RECEBER',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
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
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const gapWidth = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dashWidth).clamp(0, size.width), 0), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
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
