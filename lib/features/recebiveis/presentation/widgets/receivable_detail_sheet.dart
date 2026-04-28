import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

void showReceivableDetailSheet(
  BuildContext context, {
  required String id,
  required ReceivablesService service,
}) {
  showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      shape: const RoundedRectangleBorder(),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
        child: _ReceivableDetailSheet(id: id, service: service),
      ),
    ),
  );
}

class _ReceivableDetailSheet extends StatefulWidget {
  const _ReceivableDetailSheet({required this.id, required this.service});

  final String id;
  final ReceivablesService service;

  @override
  State<_ReceivableDetailSheet> createState() => _ReceivableDetailSheetState();
}

class _ReceivableDetailSheetState extends State<_ReceivableDetailSheet> {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  bool _loading = true;
  Receivable? _receivable;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.service.getById(widget.id);
      if (mounted) setState(() => _receivable = r);
    } on ReceivableFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(theme, colorScheme),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError(context)
                  : _buildContent(context),
        ),
        _buildFooter(context, colorScheme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    final r = _receivable;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Detalhes do recebível',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (r?.status != null) _buildStatusBadge(r!.status!, theme),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: _fetch, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final r = _receivable!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildValueHighlight(r, theme, colorScheme),
        _buildField(
          theme,
          icon: Icons.calendar_today_outlined,
          label: 'Vencimento',
          value: _dateFormat.format(r.receiptDate),
        ),
        if (r.createdAt != null)
          _buildField(
            theme,
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: _dateTimeFormat.format(r.createdAt!.toLocal()),
          ),
        if (r.updatedAt != null)
          _buildField(
            theme,
            icon: Icons.update_outlined,
            label: 'Atualizado em',
            value: _dateTimeFormat.format(r.updatedAt!.toLocal()),
          ),
        if (r.deletedAt != null)
          _buildField(
            theme,
            icon: Icons.delete_outline,
            label: 'Descartado em',
            value: _dateTimeFormat.format(r.deletedAt!.toLocal()),
            valueColor: colorScheme.error,
          ),
        _buildField(
          theme,
          icon: Icons.tag_outlined,
          label: 'ID',
          value: r.id,
          valueColor: colorScheme.onSurface.withValues(alpha: 0.45),
          valueFontSize: 12,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildValueHighlight(Receivable r, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(r.value),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    double? valueFontSize,
    bool isLast = false,
  }) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontSize: valueFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReceivableStatus status, ThemeData theme) {
    final color = status.badgeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
