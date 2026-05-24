import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';


final _cardDateFormat = DateFormat('dd/MMM/yyyy', 'pt_BR');
final _monthYearFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

bool _isCreatedToday(DateTime? createdAt) {
  if (createdAt == null) return false;
  final local = createdAt.toLocal();
  final now = DateTime.now();
  return local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
}

class ReceivableCard extends StatefulWidget {
  const ReceivableCard({
    super.key,
    required this.receivable,
    this.onDetails,
    this.onStatusChange,
    this.onDelete,
    this.compact = false,
    this.isDeleting = false,
    this.onDeleteAnimationComplete,
  });

  final Receivable receivable;
  final VoidCallback? onDetails;
  final void Function(ReceivableStatus)? onStatusChange;
  final VoidCallback? onDelete;
  final bool compact;
  final bool isDeleting;
  final VoidCallback? onDeleteAnimationComplete;

  @override
  State<ReceivableCard> createState() => _ReceivableCardState();
}

class _ReceivableCardState extends State<ReceivableCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _deleteController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteController, curve: const Interval(0.0, 0.65, curve: Curves.easeIn)),
    );
    _fadeAnim = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteController, curve: const Interval(0.0, 0.55, curve: Curves.easeIn)),
    );
    _sizeAnim = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void didUpdateWidget(ReceivableCard old) {
    super.didUpdateWidget(old);
    if (widget.isDeleting && !old.isDeleting) {
      _deleteController.forward().then((_) {
        widget.onDeleteAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

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
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: widget.onDelete,
                            icon: const Icon(Icons.delete_outline),
                            color: colorScheme.error,
                            tooltip: 'Excluir recebível',
                          ),
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
                  if (_isCreatedToday(r.createdAt))
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.70,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizeTransition(
      sizeFactor: _sizeAnim,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: _SwipeStatusWrapper(
            status: r.status,
            onAdvance: r.status.next != null ? () => widget.onStatusChange?.call(r.status.next!) : null,
            onRetrocede: r.status.previous != null ? () => widget.onStatusChange?.call(r.status.previous!) : null,
            child: card,
          ),
        ),
      ),
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
    with TickerProviderStateMixin {
  double _dragX = 0;
  double _snapStartX = 0;
  bool _triggered = false;
  ReceivableStatus? _targetStatus;
  late final AnimationController _snapController;
  late final AnimationController _pulseController;
  late final AnimationController _borderDrawController;
  late final AnimationController _borderFadeController;
  Animation<double> _pulseAnimation = const AlwaysStoppedAnimation(1.0);

  static const _triggerThreshold = 40.0;
  static const _maxDrag = 80.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_onSnapTick);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 65),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _borderDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _borderFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    _pulseController.dispose();
    _borderDrawController.dispose();
    _borderFadeController.dispose();
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
    _triggered = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final prevTriggered = _triggered;
    setState(() {
      final minDrag = widget.onAdvance != null ? -_maxDrag : 0.0;
      final maxDrag = widget.onRetrocede != null ? _maxDrag : 0.0;
      _dragX = (_dragX + d.delta.dx).clamp(minDrag, maxDrag);
      _triggered = _dragX.abs() >= _triggerThreshold;
      if (_dragX < -10 && widget.status.next != null) {
        _targetStatus = widget.status.next;
      } else if (_dragX > 10 && widget.status.previous != null) {
        _targetStatus = widget.status.previous;
      }
    });
    if (!prevTriggered && _triggered) {
      HapticFeedback.mediumImpact();
      _pulseController.forward(from: 0);
      _borderFadeController.value = 0;
      _borderDrawController.forward(from: 0);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if ((_dragX < -_triggerThreshold || v < -500) && widget.onAdvance != null) {
      widget.onAdvance!();
    } else if ((_dragX > _triggerThreshold || v > 500) && widget.onRetrocede != null) {
      widget.onRetrocede!();
    }
    _triggered = false;
    _snapStartX = _dragX;
    _snapController.forward(from: 0);
    _borderFadeController.forward(from: 0);
  }

  Widget _buildBackground(BuildContext ctx) {
    final tt = Theme.of(ctx).textTheme;
    final isDraggingLeft = _dragX < -10 && widget.onAdvance != null;
    final isDraggingRight = _dragX > 10 && widget.onRetrocede != null;

    if (isDraggingLeft) {
      final next = widget.status.next!;
      final color = next.colorFor(Theme.of(ctx).brightness);
      final progress = (-_dragX / _maxDrag).clamp(0.0, 1.0);
      final bgAlpha = _triggered ? 0.32 : 0.18 * progress;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: color.withValues(alpha: bgAlpha),
        child: Opacity(
          opacity: progress,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(next.label, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Icon(_triggered ? Icons.check_circle : Icons.arrow_forward, color: color, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    if (isDraggingRight) {
      final prev = widget.status.previous!;
      final color = prev.colorFor(Theme.of(ctx).brightness);
      final progress = (_dragX / _maxDrag).clamp(0.0, 1.0);
      final bgAlpha = _triggered ? 0.32 : 0.18 * progress;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: color.withValues(alpha: bgAlpha),
        child: Opacity(
          opacity: progress,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_triggered ? Icons.check_circle : Icons.arrow_back, color: color, size: 18),
                const SizedBox(width: 6),
                Text(prev.label, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext ctx) {
    final borderColor = _targetStatus?.colorFor(Theme.of(ctx).brightness)
        ?? Theme.of(ctx).colorScheme.primary;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackground(ctx)),
          Transform.translate(
            offset: Offset(_dragX, 0),
            child: Stack(
              children: [
                widget.child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_borderDrawController, _borderFadeController]),
                      builder: (_, _) => CustomPaint(
                        painter: _BorderProgressPainter(
                          progress: _borderDrawController.value,
                          opacity: 1.0 - _borderFadeController.value,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BorderProgressPainter extends CustomPainter {
  const _BorderProgressPainter({
    required this.progress,
    required this.opacity,
    required this.color,
  });

  final double progress;
  final double opacity;
  final Color color;

  static const _strokeWidth = 2.5;
  static const _radius = Radius.circular(12.0);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || progress <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromLTRBR(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.width - _strokeWidth / 2,
      size.height - _strokeWidth / 2,
      _radius,
    );

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
  }

  @override
  bool shouldRepaint(_BorderProgressPainter old) =>
      old.progress != progress || old.opacity != opacity || old.color != color;
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
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
                if (_isCreatedToday(r.createdAt))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
            ),
            if (r.notes != null && r.notes!.isNotEmpty)
              Align(
                alignment: const FractionalOffset(0.85, 0.0),
                child: Transform.translate(
                  offset: const Offset(0, -5),
                  child: Icon(
                    Icons.bookmark,
                    size: 26,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
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
