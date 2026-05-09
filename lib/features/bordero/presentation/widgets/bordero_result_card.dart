import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoResultCard extends StatefulWidget {
  const BorderoResultCard({
    super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final BorderoResultItem item;

  @override
  State<BorderoResultCard> createState() => _BorderoResultCardState();
}

class _BorderoResultCardState extends State<BorderoResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 280 + widget.index * 60),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_anim),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          '${widget.index + 1}',
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
                      dateFormat.format(widget.item.settlementDate),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${widget.item.interestRatePercent.toStringAsFixed(2)}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                      value: currencyFormat.format(widget.item.value),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.event_available_outlined,
                      label: 'Depósito',
                      value: dateFormat.format(widget.item.depositDate),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Dias',
                      value: '${widget.item.totalDays} dias',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.trending_down,
                      label: 'Desconto',
                      value:
                          '${widget.item.interestRatePercent.toStringAsFixed(4)}%  •  ${currencyFormat.format(widget.item.interestAmount)}',
                      iconColor: colorScheme.error,
                      valueColor: colorScheme.error,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A receber',
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          currencyFormat.format(widget.item.proceeds),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
