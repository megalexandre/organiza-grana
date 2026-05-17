import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';


final _cardDateFormat = DateFormat('dd/MMM/yyyy', 'pt_BR');
final _monthYearFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

class ReceivableCard extends StatefulWidget {
  const ReceivableCard({
    super.key,
    required this.receivable,
    this.onDetails,
    this.onStatusChange,
    this.compact = false,
  });

  final Receivable receivable;
  final VoidCallback? onDetails;
  final void Function(ReceivableStatus)? onStatusChange;
  final bool compact;

  @override
  State<ReceivableCard> createState() => _ReceivableCardState();
}

class _ReceivableCardState extends State<ReceivableCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.receivable;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget card;
    if (widget.compact) {
      card = _CompactCard(receivable: r, onDetails: widget.onDetails);
    } else {
      card = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusBadge(status: r.status),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(r.value),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'Data da Troca',
                          value: r.changeDate != null
                              ? _cardDateFormat.format(r.changeDate!)
                              : '—',
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          label: 'Data do Pagamento',
                          value: _cardDateFormat.format(r.dueDate),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'DIAS EM ESPERA',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.45),
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${r.awaitingDays}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        if (r.notes != null && r.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.notes,
                                size: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Contém observação',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.55),
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
          ),
        ),
      );
    }

    return _SwipeStatusWrapper(
      status: r.status,
      onAdvance: r.status.next != null ? () => widget.onStatusChange?.call(r.status.next!) : null,
      onRetrocede: r.status.previous != null ? () => widget.onStatusChange?.call(r.status.previous!) : null,
      child: card,
    );
  }
}

class _SwipeStatusWrapper extends StatefulWidget {
  const _SwipeStatusWrapper({
    required this.status,
    required this.child,
    this.onAdvance,
    this.onRetrocede,
  });

  final ReceivableStatus status;
  final Widget child;
  final VoidCallback? onAdvance;
  final VoidCallback? onRetrocede;

  @override
  State<_SwipeStatusWrapper> createState() => _SwipeStatusWrapperState();
}

class _SwipeStatusWrapperState extends State<_SwipeStatusWrapper>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _snapStartX = 0;
  late final AnimationController _snapController;

  static const _triggerThreshold = 40.0;
  static const _maxDrag = 80.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_onSnapTick);
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onSnapTick() {
    setState(() {
      _dragX = _snapStartX * (1 - Curves.easeOut.transform(_snapController.value));
    });
  }

  void _onDragStart(DragStartDetails _) {
    _snapController.stop();
    _snapStartX = _dragX;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      final minDrag = widget.onAdvance != null ? -_maxDrag : 0.0;
      final maxDrag = widget.onRetrocede != null ? _maxDrag : 0.0;
      _dragX = (_dragX + d.delta.dx).clamp(minDrag, maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if ((_dragX < -_triggerThreshold || v < -500) && widget.onAdvance != null) {
      widget.onAdvance!();
    } else if ((_dragX > _triggerThreshold || v > 500) && widget.onRetrocede != null) {
      widget.onRetrocede!();
    }
    _snapStartX = _dragX;
    _snapController.forward(from: 0);
  }

  Widget _buildBackground(BuildContext ctx) {
    final tt = Theme.of(ctx).textTheme;
    final isDraggingLeft = _dragX < -10 && widget.onAdvance != null;
    final isDraggingRight = _dragX > 10 && widget.onRetrocede != null;

    if (isDraggingLeft) {
      final next = widget.status.next!;
      final color = next.colorFor(Theme.of(ctx).brightness);
      final progress = (-_dragX / _maxDrag).clamp(0.0, 1.0);
      return Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: color.withValues(alpha: 0.18 * progress),
        child: Opacity(
          opacity: progress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(next.label, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: color, size: 16),
            ],
          ),
        ),
      );
    }

    if (isDraggingRight) {
      final prev = widget.status.previous!;
      final color = prev.colorFor(Theme.of(ctx).brightness);
      final progress = (_dragX / _maxDrag).clamp(0.0, 1.0);
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: color.withValues(alpha: 0.18 * progress),
        child: Opacity(
          opacity: progress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: color, size: 16),
              const SizedBox(width: 6),
              Text(prev.label, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackground(ctx)),
          Transform.translate(
            offset: Offset(_dragX, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatefulWidget {
  const _CompactCard({required this.receivable, this.onDetails});

  final Receivable receivable;
  final VoidCallback? onDetails;

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final r = widget.receivable;
    final statusColor = r.status.colorFor(colorScheme.brightness);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onDetails,
            child: Stack(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(width: 4, color: statusColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              // Valor + status
                              SizedBox(
                                width: 110,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      currencyFormat.format(r.value),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        height: 1.1,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            r.status.label,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Data de vencimento
                              Expanded(
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'VENCIMENTO',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                                          letterSpacing: 0.6,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _monthYearFormat.format(r.dueDate),
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Espera
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ESPERA',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    '${r.awaitingDays}'.padLeft(2, '0'),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (r.notes != null && r.notes!.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 8,
                    child: Icon(
                      Icons.bookmark,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReceivableStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.colorFor(Theme.of(context).brightness);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
