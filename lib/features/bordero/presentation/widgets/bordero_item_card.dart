import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoItemCard extends StatelessWidget {
  const BorderoItemCard({
    super.key,
    required this.index,
    required this.inputItem,
    required this.awaitingDays,
    required this.onRemove,
    this.onTap,
  });

  final int index;
  final BorderoInputItem inputItem;
  final int awaitingDays;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ObjectKey(inputItem),
      direction: onRemove != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      onDismissed: onRemove != null ? (_) => onRemove!() : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
                      _WaitChip(days: awaitingDays),
                      const Spacer(),
                      if (onRemove != null)
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
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Valor bruto',
                    value: currencyFormat.format(inputItem.value),
                  ),
                  if (inputItem.interestAmountCents != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.trending_down,
                      label: 'Juros',
                      value: '− ${currencyFormat.format(inputItem.interestAmountCents! / 100)}',
                      valueColor: colorScheme.error,
                    ),
                  ],
                  if (inputItem.proceedsCents != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.check_circle_outline,
                      label: 'A receber',
                      value: currencyFormat.format(inputItem.proceedsCents! / 100),
                      valueColor: colorScheme.primary,
                      valueBold: true,
                    ),
                  ],
                  if (inputItem.totalDays != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.hourglass_bottom_outlined,
                      label: 'Dias em espera',
                      value: '${inputItem.totalDays} dia${inputItem.totalDays != 1 ? 's' : ''}',
                    ),
                  ],
                  if (inputItem.depositDate != null || inputItem.settlementDate != null) ...[
                    const SizedBox(height: 8),
                    _DashedDivider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 8),
                  ],
                  if (inputItem.depositDate != null) ...[
                    _InfoRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Depósito',
                      value: dateFormat.format(inputItem.depositDate!),
                      valueColor: colorScheme.onSurfaceVariant,
                    ),
                  ],
                  if (inputItem.settlementDate != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.event_available_outlined,
                      label: 'Liquidação',
                      value: dateFormat.format(inputItem.settlementDate!),
                      valueColor: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
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
    this.valueColor,
    this.valueBold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: textTheme.bodySmall),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: valueColor,
            fontWeight: valueBold ? FontWeight.w700 : null,
          ),
        ),
      ],
    );
  }
}
