import 'package:flutter/material.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_sort.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_pagination.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/add_receivable_dialog.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/receivable_card.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/receivable_detail_sheet.dart';


class RecebiveisPage extends StatefulWidget {
  const RecebiveisPage({super.key, required this.service});

  final ReceivablesService service;

  @override
  State<RecebiveisPage> createState() => _RecebiveisPageState();
}

class _RecebiveisPageState extends State<RecebiveisPage> {
  static const int _perPage = 20;
  static const double _loadMoreThreshold = 200;

  final _scrollController = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  List<Receivable> _receivables = [];
  String? _errorMessage;
  bool _withDiscarded = false;
  ReceivablesPagination? _pagination;
  int _currentPage = 1;
  ReceivableSortField _sortBy = ReceivableSortField.dueDate;
  ReceivableSortDirection _sortDirection = ReceivableSortDirection.asc;

  static const _defaultSortBy = ReceivableSortField.dueDate;
  static const _defaultSortDirection = ReceivableSortDirection.asc;

  bool get _isSortDefault => _sortBy == _defaultSortBy && _sortDirection == _defaultSortDirection;

  String get _sortChipLabel {
    final field = _sortBy == ReceivableSortField.dueDate ? 'Vencimento' : 'Valor';
    final dir = _sortDirection == ReceivableSortDirection.asc ? '↑' : '↓';
    return '$field $dir';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadReceivables();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadReceivables() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _receivables = [];
      _currentPage = 1;
    });
    try {
      final result = await widget.service.listPage(
        page: 1,
        perPage: _perPage,
        withDiscarded: _withDiscarded,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
      if (mounted) {
        setState(() {
          _receivables = result.items;
          _pagination = result.pagination;
        });
      }
    } on ReceivableFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    final pagination = _pagination;
    if (_loadingMore || _loading || pagination == null || !pagination.hasNextPage) return;

    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final result = await widget.service.listPage(
        page: nextPage,
        perPage: _perPage,
        withDiscarded: _withDiscarded,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _receivables = [..._receivables, ...result.items];
          _pagination = result.pagination;
        });
      }
    } on ReceivableFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            action: SnackBarAction(label: 'Tentar novamente', onPressed: _loadMore),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AddReceivableDialog(service: widget.service),
    );
    if (created == true) _loadReceivables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        tooltip: 'Novo recebível',
        child: const Icon(Icons.add),
      ),
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
          _FilterButton(
            active: _withDiscarded,
            onPressed: () => _showFiltersSheet(context),
          ),
          const SizedBox(width: 8),
          _SortButton(
            active: !_isSortDefault,
            onPressed: () => _showSortSheet(context),
          ),
          const SizedBox(width: 8),
          if (_withDiscarded)
            Chip(
              label: const Text('Com descartados'),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                setState(() => _withDiscarded = false);
                _loadReceivables();
              },
            ),
          if (!_isSortDefault) ...[
            if (_withDiscarded) const SizedBox(width: 4),
            Chip(
              label: Text(_sortChipLabel),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                setState(() {
                  _sortBy = _defaultSortBy;
                  _sortDirection = _defaultSortDirection;
                });
                _loadReceivables();
              },
            ),
          ],
          const Spacer(),
          if (_pagination != null)
            Text(
              '${_receivables.length} / ${_pagination!.totalCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: const RoundedRectangleBorder(),
          title: const Text('Ordenação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ordenar por', style: Theme.of(context).textTheme.labelMedium),
              RadioGroup<ReceivableSortField>(
                groupValue: _sortBy,
                onChanged: (v) {
                  if (v == null) return;
                  setModalState(() {});
                  Navigator.pop(context);
                  setState(() => _sortBy = v);
                  _loadReceivables();
                },
                child: Column(
                  children: [
                    RadioListTile<ReceivableSortField>(
                      title: const Text('Data de vencimento'),
                      value: ReceivableSortField.dueDate,
                    ),
                    RadioListTile<ReceivableSortField>(
                      title: const Text('Valor'),
                      value: ReceivableSortField.amount,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Text('Direção', style: Theme.of(context).textTheme.labelMedium),
              RadioGroup<ReceivableSortDirection>(
                groupValue: _sortDirection,
                onChanged: (v) {
                  if (v == null) return;
                  setModalState(() {});
                  Navigator.pop(context);
                  setState(() => _sortDirection = v);
                  _loadReceivables();
                },
                child: Column(
                  children: [
                    RadioListTile<ReceivableSortDirection>(
                      title: const Text('Mais recente primeiro'),
                      value: ReceivableSortDirection.desc,
                    ),
                    RadioListTile<ReceivableSortDirection>(
                      title: const Text('Mais antigo primeiro'),
                      value: ReceivableSortDirection.asc,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: const RoundedRectangleBorder(),
          title: const Text('Filtros'),
          content: CheckboxListTile(
            title: const Text('Exibir descartados'),
            value: _withDiscarded,
            onChanged: (v) {
              setModalState(() {});
              Navigator.pop(context);
              setState(() => _withDiscarded = v ?? false);
              _loadReceivables();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _receivables.isEmpty) {
      return _buildErrorState(textTheme);
    }

    if (_receivables.isEmpty) {
      return _buildEmptyState(colorScheme, textTheme);
    }

    final hasMore = _pagination?.hasNextPage ?? false;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _receivables.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _receivables.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final r = _receivables[index];
        return ReceivableCard(
          receivable: r,
          onDetails: () => showReceivableDetailSheet(
            context,
            id: r.id,
            service: widget.service,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.3)),
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
          TextButton(onPressed: _loadReceivables, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7);
    final borderColor = active ? colorScheme.primary : colorScheme.outlineVariant;
    final bg = active ? colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7);
    final borderColor = active ? colorScheme.primary : colorScheme.outlineVariant;
    final bg = active ? colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              'Ordenar',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
