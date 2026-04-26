import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:organizagrana/features/auth/data/auth_access_token_provider.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/add_receivable_dialog.dart';

enum _ReceivableColumnId { value, receiptDate, status }

class _ReceivableTableColumn {
  const _ReceivableTableColumn({
    required this.id,
    required this.label,
    required this.width,
  });

  final _ReceivableColumnId id;
  final String label;
  final double width;
}

class RecebiveisPage extends StatefulWidget {
  const RecebiveisPage({super.key});

  @override
  State<RecebiveisPage> createState() => _RecebiveisPageState();
}

class _RecebiveisPageState extends State<RecebiveisPage> {
  static const int _perPage = 10;
  static const double _paginationButtonWidth = 124;
  static const double _paginationInfoWidth = 140;
  static const double _statusBadgeWidth = 128;

  late final ReceivablesService _service;
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  bool _loading = true;
  String? _errorMessage;
  List<Receivable> _receivables = const [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _withDiscarded = false;

  // Filter accordion
  bool _filtersExpanded = false;
  bool _pendingWithDiscarded = false;

  _ReceivableColumnId _sortBy = _ReceivableColumnId.receiptDate;
  bool _sortAscending = true;
  final List<_ReceivableTableColumn> _columns = const [
    _ReceivableTableColumn(
      id: _ReceivableColumnId.value,
      label: 'Valor',
      width: 220,
    ),
    _ReceivableTableColumn(
      id: _ReceivableColumnId.receiptDate,
      label: 'Data de vencimento',
      width: 260,
    ),
    _ReceivableTableColumn(
      id: _ReceivableColumnId.status,
      label: 'Status',
      width: 220,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _service = ReceivablesService(
      HttpReceivablesApiClient(
        AuthStorageAccessTokenProvider(AuthStorage()),
      ),
    );
    _loadReceivables();
  }

  Future<void> _loadReceivables({int? page}) async {
    final nextPage = page ?? _currentPage;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.listPage(
        page: nextPage,
        perPage: _perPage,
        withDiscarded: _withDiscarded,
      );
      if (!mounted) return;
      setState(() {
        _receivables = result.items;
        _currentPage = result.pagination.currentPage;
        _totalPages = result.pagination.totalPages;
        _totalCount = result.pagination.totalCount;
      });
    } on ReceivableFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _changePage(int page) async {
    if (_loading || page < 1 || page > _totalPages || page == _currentPage) {
      return;
    }

    await _loadReceivables(page: page);
  }

  void _applyFilters() {
    setState(() {
      _withDiscarded = _pendingWithDiscarded;
      _filtersExpanded = false;
    });
    _loadReceivables(page: 1);
  }

  void _clearFilters() {
    setState(() {
      _pendingWithDiscarded = false;
    });
  }

  Future<void> _openAddDialog() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddReceivableDialog(service: _service),
    );

    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recebível adicionado com sucesso.')),
      );
      await _loadReceivables();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recebíveis',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acompanhe os valores previstos e recebidos em um único lugar.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _loadReceivables,
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          _buildFilterAccordeon(context),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildFilterAccordeon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
        color: colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _filtersExpanded = !_filtersExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _filtersExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _pendingWithDiscarded,
                        onSelected: (v) =>
                            setState(() => _pendingWithDiscarded = v),
                        label: const Text('Incluir descartados'),
                        avatar:
                            const Icon(Icons.delete_outline, size: 18),
                        showCheckmark: false,
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _loading ? null : _applyFilters,
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading && _receivables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadReceivables,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_receivables.isEmpty) {
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
            Text(
              'Nenhum recebível cadastrado.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (_withDiscarded) ...[
              const SizedBox(height: 8),
              Text(
                'O filtro de descartados está ativo.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return IgnorePointer(
      ignoring: _loading,
      child: AnimatedOpacity(
        opacity: _loading ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.75),
                  ),
                ),
                child: TableView.builder(
                  columns: _columns
                      .map((column) => TableColumn(width: column.width))
                      .toList(),
                  minScrollableWidth: 540,
                  rowCount: _sortedReceivables.length,
                  rowHeight: 60,
                  headerHeight: 56,
                  style: TableViewStyle(
                    scrollbars: const TableViewScrollbarsStyle.symmetric(
                      TableViewScrollbarStyle(
                        enabled: TableViewScrollbarEnabled.auto,
                        interactive: true,
                      ),
                    ),
                    dividers: TableViewDividersStyle(
                      horizontal: TableViewHorizontalDividersStyle.symmetric(
                        TableViewHorizontalDividerStyle(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.45),
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),
                  headerBuilder: (context, contentBuilder) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.55),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    child: contentBuilder(
                      context,
                      (context, column) => _buildHeaderCell(context, column),
                    ),
                  ),
                  rowBuilder: (context, row, contentBuilder) {
                    final item = _sortedReceivables[row];
                    return ColoredBox(
                      color: row.isEven
                          ? colorScheme.surface
                          : colorScheme.primaryContainer
                              .withValues(alpha: 0.06),
                      child: contentBuilder(
                        context,
                        (context, column) =>
                            _buildDataCell(context, column, item),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildTableFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTableFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final startItem =
        _totalCount == 0 ? 0 : ((_currentPage - 1) * _perPage) + 1;
    final endItem = _totalCount == 0
        ? 0
        : math.min(startItem + _receivables.length - 1, _totalCount);
    final pageAmount =
        _sortedReceivables.fold<double>(0, (s, r) => s + r.value);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.75)),
          right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.75)),
          bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.75)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(
                  color:
                      colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                _buildFooterStat(
                  context,
                  label: 'Nesta página',
                  value: '${_sortedReceivables.length} itens',
                ),
                _buildFooterDivider(context),
                _buildFooterStat(
                  context,
                  label: 'Total da página',
                  value: _currency.format(pageAmount),
                  valueColor: colorScheme.primary,
                ),
                _buildFooterDivider(context),
                _buildFooterStat(
                  context,
                  label: 'Total geral',
                  value: '$_totalCount recebíveis',
                ),
              ],
            ),
          ),
          // Pagination row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mostrando $startItem–$endItem de $_totalCount',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                SizedBox(
                  width: _paginationButtonWidth,
                  child: OutlinedButton.icon(
                    onPressed: _currentPage > 1
                        ? () => _changePage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('Anterior'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  width: _paginationInfoWidth,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    'Página $_currentPage de $_totalPages',
                    textAlign: TextAlign.center,
                    style: textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: _paginationButtonWidth,
                  child: FilledButton.icon(
                    onPressed: _currentPage < _totalPages
                        ? () => _changePage(_currentPage + 1)
                        : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('Próxima'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  List<Receivable> get _sortedReceivables {
    final items = [..._receivables];
    items.sort((a, b) {
      final comparison = switch (_sortBy) {
        _ReceivableColumnId.value => a.value.compareTo(b.value),
        _ReceivableColumnId.receiptDate =>
          a.receiptDate.compareTo(b.receiptDate),
        _ReceivableColumnId.status => _normalizedStatus(a)
            .toLowerCase()
            .compareTo(_normalizedStatus(b).toLowerCase()),
      };
      return _sortAscending ? comparison : -comparison;
    });
    return items;
  }

  String _normalizedStatus(Receivable receivable) {
    return receivable.status?.label ?? 'Pendente';
  }

  void _sortByColumn(_ReceivableColumnId columnId) {
    setState(() {
      if (_sortBy == columnId) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = columnId;
        _sortAscending = true;
      }
    });
  }

  Widget _buildHeaderCell(BuildContext context, int column) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final header = _columns[column];
    final isSortedColumn = _sortBy == header.id;
    final sortIcon = isSortedColumn
        ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.unfold_more;

    return InkWell(
      onTap: () => _sortByColumn(header.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: _columnAlignment(header.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  header.label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: _textAlignFor(header.id),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                sortIcon,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, int column, Receivable item) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final columnId = _columns[column].id;
    final status = _normalizedStatus(item);
    late final Widget content;

    switch (columnId) {
      case _ReceivableColumnId.value:
        content = Text(
          _currency.format(item.value),
          textAlign: TextAlign.right,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        );
      case _ReceivableColumnId.receiptDate:
        content = Text(
          _dateFormat.format(item.receiptDate),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        );
      case _ReceivableColumnId.status:
        content = Container(
          width: _statusBadgeWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _statusBackgroundColor(item, colorScheme),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: _statusForegroundColor(item, colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Align(
        alignment: _columnAlignment(columnId),
        child: content,
      ),
    );
  }

  Alignment _columnAlignment(_ReceivableColumnId columnId) {
    return switch (columnId) {
      _ReceivableColumnId.value => Alignment.centerRight,
      _ReceivableColumnId.receiptDate => Alignment.center,
      _ReceivableColumnId.status => Alignment.center,
    };
  }

  TextAlign _textAlignFor(_ReceivableColumnId columnId) {
    return switch (columnId) {
      _ReceivableColumnId.value => TextAlign.right,
      _ReceivableColumnId.receiptDate => TextAlign.center,
      _ReceivableColumnId.status => TextAlign.center,
    };
  }

  Color _statusBackgroundColor(Receivable item, ColorScheme colorScheme) {
    return switch (item.status) {
      ReceivableStatus.paid => Colors.green.withValues(alpha: 0.12),
      ReceivableStatus.overdue => colorScheme.error.withValues(alpha: 0.12),
      ReceivableStatus.inAnalysis => Colors.orange.withValues(alpha: 0.12),
      ReceivableStatus.inTransaction => colorScheme.primary.withValues(alpha: 0.12),
      _ => colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
    };
  }

  Color _statusForegroundColor(Receivable item, ColorScheme colorScheme) {
    return switch (item.status) {
      ReceivableStatus.paid => Colors.green.shade700,
      ReceivableStatus.overdue => colorScheme.error,
      ReceivableStatus.inAnalysis => Colors.orange.shade800,
      ReceivableStatus.inTransaction => colorScheme.primary,
      _ => colorScheme.onSurface.withValues(alpha: 0.82),
    };
  }
}
