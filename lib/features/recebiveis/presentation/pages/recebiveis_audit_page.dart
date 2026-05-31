import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/features/recebiveis/data/receivable_audits_api_client.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_audit.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/layout/page_content_constraint.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class RecebiveisAuditPage extends StatefulWidget {
  const RecebiveisAuditPage({super.key, required this.apiClient});

  final ReceivableAuditsApiClient apiClient;

  @override
  State<RecebiveisAuditPage> createState() => _RecebiveisAuditPageState();
}

class _RecebiveisAuditPageState extends State<RecebiveisAuditPage> {
  static const int _perPage = 30;
  static const double _loadMoreThreshold = 200;

  final _scrollController = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  List<ReceivableAudit> _audits = [];
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _audits = [];
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final result = await widget.apiClient.listPage(page: 1, perPage: _perPage);
      setState(() {
        _audits = result.audits;
        _hasMore = result.hasMore;
        _currentPage = 1;
      });
    } catch (_) {
      setState(() => _errorMessage = 'Erro ao carregar auditoria.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final result = await widget.apiClient.listPage(page: nextPage, perPage: _perPage);
      setState(() {
        _audits.addAll(result.audits);
        _hasMore = result.hasMore;
        _currentPage = nextPage;
      });
    } catch (_) {
      // silently ignore load-more errors
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PageContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.history, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          'Auditoria de Recebíveis',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: 'Atualizar',
          onPressed: _loading ? null : _load,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return _buildSkeleton();
    if (_errorMessage != null) return _buildError();
    if (_audits.isEmpty) return _buildEmpty(context);
    return _buildTimeline(context);
  }

  Widget _buildTimeline(BuildContext context) {
    final grouped = _groupByDate(_audits);
    final dateKeys = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: dateKeys.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= dateKeys.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final dateKey = dateKeys[index];
          final items = grouped[dateKey]!;
          return _buildDateGroup(context, dateKey, items);
        },
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, String dateLabel, List<ReceivableAudit> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            children: [
              Text(
                dateLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outlineVariant,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final audit = entry.value;
          final isLast = i == items.length - 1;
          return _AuditEventTile(audit: audit, isLast: isLast);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, _) => const _SkeletonTile(),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_outlined,
              size: 48, color: theme.colorScheme.onSurface.withAlpha(60)),
          const SizedBox(height: 12),
          Text(
            'Nenhuma alteração registrada',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage ?? 'Erro desconhecido'),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }

  Map<String, List<ReceivableAudit>> _groupByDate(List<ReceivableAudit> audits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final result = <String, List<ReceivableAudit>>{};

    for (final audit in audits) {
      final d = audit.createdAt.toLocal();
      final day = DateTime(d.year, d.month, d.day);
      final String label;
      if (day == today) {
        label = 'HOJE';
      } else if (day == yesterday) {
        label = 'ONTEM';
      } else {
        label = DateFormat('dd/MM/yyyy').format(day).toUpperCase();
      }
      (result[label] ??= []).add(audit);
    }

    return result;
  }
}

class _AuditEventTile extends StatelessWidget {
  const _AuditEventTile({required this.audit, required this.isLast});

  final ReceivableAudit audit;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = _eventColor(theme, brightness);
    final timeStr = DateFormat('HH:mm').format(audit.createdAt.toLocal());

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _EventChip(audit: audit, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ..._buildChangeRows(theme, brightness),
                  Text(
                    '#${audit.receivableId.substring(0, 8)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(ThemeData theme, Brightness brightness) {
    if (audit.isDestroy) return theme.colorScheme.error;
    if (audit.isCreate) return theme.colorScheme.primary;
    if (audit.isStatusChange) {
      final newStatus = audit.changes['status'];
      final statusStr = newStatus is List ? newStatus.last?.toString() : newStatus?.toString();
      final status = ReceivableStatus.fromJson(statusStr);
      if (status != null) return status.colorFor(brightness);
    }
    return AppColors.statusToDeposit;
  }

  List<Widget> _buildChangeRows(ThemeData theme, Brightness brightness) {
    if (audit.isCreate) {
      final amountRaw = audit.changes['amount_cents'];
      final amount = amountRaw is List ? amountRaw.last : amountRaw;
      if (amount != null) {
        final value = (amount as num).toInt() / 100;
        return [
          Text(
            currencyFormat.format(value),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(160),
            ),
          ),
        ];
      }
    }

    final rows = <Widget>[];
    for (final entry in audit.changes.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val is! List || val.length < 2) continue;
      final oldVal = val[0];
      final newVal = val[1];
      final label = _fieldLabel(key);
      final oldStr = _formatValue(key, oldVal);
      final newStr = _formatValue(key, newVal);
      rows.add(
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
            ),
            TextSpan(
              text: oldStr,
              style: theme.textTheme.labelSmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.error.withAlpha(180),
              ),
            ),
            TextSpan(
              text: ' → ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ),
            TextSpan(
              text: newStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(200),
              ),
            ),
          ]),
        ),
      );
    }
    return rows;
  }

  String _fieldLabel(String key) => switch (key) {
        'status' => 'Status',
        'amount_cents' => 'Valor',
        'due_date' => 'Vencimento',
        'notes' => 'Observação',
        'change_date' => 'Data do status',
        'deleted_at' => 'Exclusão',
        _ => key,
      };

  String _formatValue(String key, dynamic value) {
    if (value == null) return '—';
    if (key == 'amount_cents') {
      final cents = (value as num).toInt();
      return currencyFormat.format(cents / 100);
    }
    if (key == 'status') {
      return ReceivableStatus.fromJson(value.toString())?.label ?? value.toString();
    }
    if (key == 'due_date' || key == 'change_date') {
      final d = DateTime.tryParse(value.toString());
      if (d != null) return dateFormat.format(d);
    }
    return value.toString();
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.audit, required this.color});

  final ReceivableAudit audit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label) = _iconAndLabel();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  (IconData, String) _iconAndLabel() {
    if (audit.isDestroy) return (Icons.delete_outline, 'Excluído');
    if (audit.isCreate) return (Icons.add_circle_outline, 'Criado');
    if (audit.isStatusChange) return (Icons.swap_horiz, 'Status alterado');
    return (Icons.edit_outlined, 'Editado');
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: base, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 80, color: base),
                const SizedBox(height: 6),
                Container(height: 10, width: 200, color: base),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
