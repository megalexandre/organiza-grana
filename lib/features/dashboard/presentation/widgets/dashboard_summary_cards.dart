import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_summary.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

/// Faixa de KPIs "Resumo financeiro" no topo do dashboard: total a receber,
/// quantidade de recebíveis e prazo médio de espera.
class DashboardSummaryCards extends StatefulWidget {
  const DashboardSummaryCards({super.key, required this.service});

  final DashboardService service;

  @override
  State<DashboardSummaryCards> createState() => _DashboardSummaryCardsState();
}

class _DashboardSummaryCardsState extends State<DashboardSummaryCards> {
  bool _loading = true;
  String? _errorMessage;
  DashboardSummary? _summary;

  // Recarrega ao voltar para a rota do dashboard (mesmo padrão do painel de
  // status), para os números não ficarem defasados após editar recebíveis.
  RouteInformationProvider? _routeInfoProvider;
  String _lastLocation = AppRouter.dashboardPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final summary = await widget.service.fetchSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
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
    if (_errorMessage != null) {
      return _SummaryError(message: _errorMessage!, onRetry: _load);
    }

    final summary = _summary;
    final cards = <Widget>[
      _StatCard(
        icon: Icons.account_balance_wallet_outlined,
        label: 'A receber',
        value: summary == null ? null : currencyFormat.format(summary.totalProceeds),
        loading: _loading,
      ),
      _StatCard(
        icon: Icons.receipt_long_outlined,
        label: 'Recebíveis',
        value: summary == null ? null : '${summary.receivablesCount}',
        loading: _loading,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Em telas estreitas os cartões empilham; em largas ficam lado a lado.
        final isNarrow = constraints.maxWidth < 360;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards)
              SizedBox(
                width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                child: card,
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.loading,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading || value == null)
              Container(
                height: 22,
                width: 100,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Text(
                value!,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
              message,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
