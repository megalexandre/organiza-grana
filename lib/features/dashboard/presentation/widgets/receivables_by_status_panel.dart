import 'package:flutter/material.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';

class ReceivablesByStatusPanel extends StatefulWidget {
  const ReceivablesByStatusPanel({super.key, required this.service});

  final DashboardService service;

  @override
  State<ReceivablesByStatusPanel> createState() => _ReceivablesByStatusPanelState();
}

class _ReceivablesByStatusPanelState extends State<ReceivablesByStatusPanel> {
  bool _loading = true;
  String? _errorMessage;
  Map<ReceivableStatus, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final items = await widget.service.fetchReceivablesByStatus();
      if (!mounted) return;
      setState(() {
        _counts = {for (final item in items) item.status: item.count};
        _loading = false;
      });
    } on DashboardFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt_long_outlined, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'Recebíveis por status',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (!_loading && _errorMessage == null)
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Atualizar',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          _buildSkeleton(colorScheme)
        else if (_errorMessage != null)
          _buildError(colorScheme, textTheme)
        else
          _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    final statuses = ReceivableStatus.values;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final status in statuses)
              SizedBox(
                width: cardWidth,
                child: _StatusCard(
                  status: status,
                  count: _counts[status] ?? 0,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < 6; i++)
              _SkeletonCard(width: cardWidth, colorScheme: colorScheme),
          ],
        );
      },
    );
  }

  Widget _buildError(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(onPressed: _load, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.count});

  final ReceivableStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final statusColor = status.colorFor(brightness);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: statusColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.width, required this.colorScheme});

  final double width;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final shimmer = colorScheme.onSurface.withValues(alpha: 0.08);
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 4, color: shimmer),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 80, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(height: 28, width: 40, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
