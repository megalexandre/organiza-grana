import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  RouteInformationProvider? _routeInfoProvider;
  String _lastLocation = AppRouter.dashboardPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = GoRouter.of(context).routeInformationProvider;
    if (_routeInfoProvider != provider) {
      _routeInfoProvider?.removeListener(_onRouteChanged);
      _routeInfoProvider = provider;
      _routeInfoProvider!.addListener(_onRouteChanged);
    }
  }

  @override
  void dispose() {
    _routeInfoProvider?.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final path = _routeInfoProvider?.value.uri.path ?? '';
    if (path == AppRouter.dashboardPath && _lastLocation != AppRouter.dashboardPath) {
      _load();
    }
    _lastLocation = path;
  }

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

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                const SizedBox(height: 8),
                if (_loading)
                  _buildSkeleton(colorScheme)
                else if (_errorMessage != null)
                  _buildError(colorScheme, textTheme)
                else
                  _buildChart(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final total = _counts.values.fold(0, (sum, c) => sum + c);

    if (total == 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Nenhum recebível encontrado.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final data = ReceivableStatus.values
        .where((s) => (_counts[s] ?? 0) > 0)
        .map((s) => _ChartPoint(s, _counts[s]!, s.colorFor(brightness)))
        .toList();

    return Column(
      children: [
        SfCircularChart(
          margin: EdgeInsets.zero,
          series: [
            PieSeries<_ChartPoint, String>(
              dataSource: data,
              xValueMapper: (p, _) => p.status.label,
              yValueMapper: (p, _) => p.count,
              pointColorMapper: (p, _) => p.color,
              strokeColor: Theme.of(context).colorScheme.surface,
              animationDuration: 0,
              explode: true,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                connectorLineSettings: ConnectorLineSettings(
                  color: colorScheme.outlineVariant,
                  length: '8%',
                ),
              ),
              dataLabelMapper: (p, _) => '${p.count}',
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildLegend(data, textTheme, colorScheme),
      ],
    );
  }

  Widget _buildLegend(
    List<_ChartPoint> data,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final point in data)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: point.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                point.status.label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSkeleton(ColorScheme colorScheme) {
    final shimmer = colorScheme.onSurface.withValues(alpha: 0.08);
    return Center(
      child: Container(
        width: 180,
        height: 180,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: shimmer, shape: BoxShape.circle),
      ),
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

class _ChartPoint {
  const _ChartPoint(this.status, this.count, this.color);

  final ReceivableStatus status;
  final int count;
  final Color color;
}
