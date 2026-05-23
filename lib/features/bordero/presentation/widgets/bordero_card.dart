import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoCard extends StatelessWidget {
  const BorderoCard({
    super.key,
    required this.bordero,
    this.compact = true,
    this.onTap,
  });

  final SavedBordero bordero;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactCard(bordero: bordero, onTap: onTap) : _ExpandedCard(bordero: bordero, onTap: onTap);
  }
}

class _ExpandedCard extends StatelessWidget {
  const _ExpandedCard({required this.bordero, this.onTap});

  final SavedBordero bordero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final rateFormatted = '${bordero.monthlyRatePercent.toStringAsFixed(2).replaceAll('.', ',')}% a.m.';

    return _CardShell(
      accentColor: cs.onSurface,
      outlineColor: cs.outlineVariant,
      surfaceColor: cs.surface,
      shadowColor: cs.shadow,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(bordero.changeDate),
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rateFormatted,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(bordero.totalAmount),
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.bordero, this.onTap});

  final SavedBordero bordero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final rateFormatted = '${bordero.monthlyRatePercent.toStringAsFixed(2).replaceAll('.', ',')}%';

    return _CardShell(
      accentColor: cs.onSurface,
      outlineColor: cs.outlineVariant,
      surfaceColor: cs.surface,
      shadowColor: cs.shadow,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(bordero.changeDate),
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    rateFormatted,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(bordero.totalAmount),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    currencyFormat.format(bordero.totalProceeds),
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.accentColor,
    required this.outlineColor,
    required this.surfaceColor,
    required this.shadowColor,
    required this.child,
    this.onTap,
  });

  final Color accentColor;
  final Color outlineColor;
  final Color surfaceColor;
  final Color shadowColor;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          left: BorderSide(color: outlineColor),
          top: BorderSide(color: outlineColor),
          right: BorderSide(color: outlineColor),
          bottom: BorderSide(color: outlineColor),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
