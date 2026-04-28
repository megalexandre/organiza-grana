import 'package:flutter/material.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_pagination.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/receivable_card.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/receivable_detail_sheet.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class RecebiveisPage extends StatefulWidget {
  const RecebiveisPage({super.key, required this.service});

  final ReceivablesService service;

  @override
  State<RecebiveisPage> createState() => _RecebiveisPageState();
}

class _RecebiveisPageState extends State<RecebiveisPage> {
  static const int _perPage = 20;
  static const double _wideBreakpoint = 600;

  bool _loading = false;
  List<Receivable> _receivables = [];
  String? _errorMessage;
  bool _withDiscarded = false;
  ReceivablesPagination? _pagination;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadReceivables();
  }

  Future<void> _loadReceivables() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await widget.service.listPage(
        page: _currentPage,
        perPage: _perPage,
        withDiscarded: _withDiscarded,
      );
      if (mounted) {
        setState(() {
          _receivables = result.items;
          _pagination = result.pagination;
        });
      }
    } on ReceivableFailure catch (e) {
      if (!mounted) return;
      if (_receivables.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            action: SnackBarAction(label: 'Tentar novamente', onPressed: _loadReceivables),
          ),
        );
      } else {
        setState(() => _errorMessage = e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _loadReceivables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recebíveis')),
      body: Column(
        children: [
          _buildToolbar(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => _showFiltersSheet(context),
            icon: const Icon(Icons.tune, size: 16),
            label: const Text('Filtros'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          if (_withDiscarded)
            Chip(
              label: const Text('Com descartados'),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                setState(() {
                  _withDiscarded = false;
                  _currentPage = 1;
                });
                _loadReceivables();
              },
            ),
        ],
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: CheckboxListTile(
          title: const Text('Exibir descartados'),
          value: _withDiscarded,
          onChanged: (v) {
            Navigator.pop(context);
            setState(() {
              _withDiscarded = v ?? false;
              _currentPage = 1;
            });
            _loadReceivables();
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading && _receivables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _receivables.isEmpty) {
      return _buildErrorState(textTheme);
    }

    if (_receivables.isEmpty) {
      return _buildEmptyState(colorScheme, textTheme);
    }

    return IgnorePointer(
      ignoring: _loading,
      child: AnimatedOpacity(
        opacity: _loading ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _receivables.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = _receivables[index];
                  return ReceivableCard(
                    receivable: r,
                    onDetails: () => showReceivableDetailSheet(
                      context,
                      id: r.id,
                      service: widget.service,
                    ),
                    onReceive: null,
                  );
                },
              ),
            ),
            _buildTableFooter(context),
          ],
        ),
      ),
    );
  }


  Widget _buildTableFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final pagination = _pagination;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${pagination?.totalCount ?? _receivables.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (isWide)
                Text(
                  'Soma (pág.): ${currencyFormat.format(_receivables.fold(0.0, (sum, r) => sum + r.value))}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (pagination != null && pagination.totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: pagination.hasPreviousPage
                      ? () => _goToPage(_currentPage - 1)
                      : null,
                ),
                Text('${pagination.currentPage} / ${pagination.totalPages}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: pagination.hasNextPage
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text('Nenhum recebível encontrado.', style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadReceivables,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
