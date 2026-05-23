import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/borderos_pagination.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_card.dart';
import 'package:organizagrana/shared/layout/page_content_constraint.dart';

class BorderosListPage extends StatefulWidget {
  const BorderosListPage({super.key, required this.service});

  final BorderoService service;

  @override
  State<BorderosListPage> createState() => _BorderosListPageState();
}

class _BorderosListPageState extends State<BorderosListPage> {
  static const int _perPage = 20;
  static const double _loadMoreThreshold = 200;

  final _scrollController = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  List<SavedBordero> _borderos = [];
  String? _errorMessage;
  BorderosPagination? _pagination;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBorderos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) _loadMore();
  }

  Future<void> _loadBorderos() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _borderos = [];
      _currentPage = 1;
    });
    try {
      final result = await widget.service.listPage(page: 1, perPage: _perPage);
      if (mounted) setState(() { _borderos = result.items; _pagination = result.pagination; });
    } on BorderoFailure catch (e) {
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
      final result = await widget.service.listPage(page: nextPage, perPage: _perPage);
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _borderos = [..._borderos, ...result.items];
          _pagination = result.pagination;
        });
      }
    } on BorderoFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message),
          action: SnackBarAction(label: 'Tentar novamente', onPressed: _loadMore),
        ));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openNovoBordero() async {
    final created = await context.push<bool>(AppRouter.borderoNovoPath);
    if (created == true) _loadBorderos();
  }

  Future<void> _openBordero(String borderoId) async {
    final updated = await context.push<bool>(AppRouter.borderoNovoPath, extra: borderoId);
    if (updated == true) _loadBorderos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openNovoBordero,
        tooltip: 'Novo borderô',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null && _borderos.isEmpty) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadBorderos);
    }
    if (_borderos.isEmpty) return const _EmptyState();

    final hasMore = _pagination?.hasNextPage ?? false;

    return PageContentConstraint(
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + MediaQuery.of(context).padding.bottom),
        itemCount: _borderos.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _borderos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final b = _borderos[index];
          return BorderoCard(
            key: ValueKey(b.id),
            bordero: b,
            onTap: () => _openBordero(b.id),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Nenhum borderô salvo.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
