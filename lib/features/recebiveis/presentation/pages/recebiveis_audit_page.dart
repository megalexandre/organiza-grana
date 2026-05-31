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

  // Groups audits by receivable_id preserving the order of first appearance
  // (API returns newest-first, so groups are ordered by most-recent event desc).
  // Events within each group are reversed to show oldest→newest.
  List<_ReceivableGroup> _buildGroups(List<ReceivableAudit> audits) {
    final order = <String>[];
    final map = <String, List<ReceivableAudit>>{};
    for (final a in audits) {
      if (!map.containsKey(a.receivableId)) {
        order.add(a.receivableId);
        map[a.receivableId] = [];
      }
      map[a.receivableId]!.add(a);
    }
    return order.map((id) {
      final events = map[id]!.reversed.toList(); // oldest first
      return _ReceivableGroup(receivableId: id, events: events);
    }).toList();
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

    final groups = _buildGroups(_audits);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: groups.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= groups.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ReceivableAuditCard(group: groups[index]),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, _) => const _SkeletonCard(),
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
}

class _ReceivableGroup {
  const _ReceivableGroup({required this.receivableId, required this.events});
  final String receivableId;
  final List<ReceivableAudit> events;
  ReceivableAudit get latest => events.last;
}

class _ReceivableAuditCard extends StatelessWidget {
  const _ReceivableAuditCard({required this.group});

  final _ReceivableGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sample = group.latest;
    final amountCents = sample.receivableAmountCents;
    final dueDate = sample.receivableDueDate;

    final sequenceNumber = group.latest.receivableSequenceNumber;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                if (sequenceNumber != null) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$sequenceNumber',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
                if (amountCents != null)
                  Text(
                    currencyFormat.format(amountCents / 100),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (amountCents != null && dueDate != null)
                  Text(
                    '  ·  Venc ${dateFormat.format(dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                const Spacer(),
                Text(
                  '#${group.receivableId.substring(0, 8)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(80),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          // Events timeline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: group.events.asMap().entries.map((entry) {
                final isLast = entry.key == group.events.length - 1;
                return _AuditEventTile(audit: entry.value, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _EventChip(audit: audit, color: color),
                    ],
                  ),
                  ..._buildChangeRows(theme, brightness),
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
    if (audit.isCreate) return [];

    final rows = <Widget>[];
    for (final entry in audit.changes.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val is! List || val.length < 2) continue;
      final oldStr = _formatValue(key, val[0]);
      final newStr = _formatValue(key, val[1]);
      rows.add(
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${_fieldLabel(key)}: ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
            ),
            TextSpan(
              text: oldStr,
              style: theme.textTheme.labelSmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.error.withAlpha(160),
              ),
            ),
            TextSpan(
              text: ' → $newStr',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
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
        'notes' => 'Obs.',
        'change_date' => 'Data status',
        'deleted_at' => 'Exclusão',
        _ => key,
      };

  String _formatValue(String key, dynamic value) {
    if (value == null) return '—';
    if (key == 'amount_cents') return currencyFormat.format((value as num).toInt() / 100);
    if (key == 'status') return ReceivableStatus.fromJson(value.toString())?.label ?? value.toString();
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
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, width: 160, color: base),
          const SizedBox(height: 12),
          Container(height: 10, width: 240, color: base),
          const SizedBox(height: 8),
          Container(height: 10, width: 200, color: base),
        ],
      ),
    );
  }
}
