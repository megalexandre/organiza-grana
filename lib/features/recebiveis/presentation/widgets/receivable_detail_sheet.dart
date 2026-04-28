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
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _ReceivableDetailSheet(id: id, service: service),
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
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          _buildHandle(context),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(context)
                    : _buildContent(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
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

  Widget _buildContent(BuildContext context, ScrollController controller) {
    final r = _receivable!;
    final theme = Theme.of(context);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Detalhes do recebível', style: theme.textTheme.titleLarge),
            ),
            if (r.status != null) _buildStatusBadge(r.status!, theme),
          ],
        ),
        const SizedBox(height: 24),
        _buildRow(
          context,
          icon: Icons.attach_money,
          label: 'Valor',
          value: currencyFormat.format(r.value),
          valueStyle: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        _buildDivider(),
        _buildRow(
          context,
          icon: Icons.calendar_today_outlined,
          label: 'Vencimento',
          value: _dateFormat.format(r.receiptDate),
        ),
        if (r.createdAt != null) ...[
          _buildDivider(),
          _buildRow(
            context,
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: _dateTimeFormat.format(r.createdAt!.toLocal()),
          ),
        ],
        if (r.updatedAt != null) ...[
          _buildDivider(),
          _buildRow(
            context,
            icon: Icons.update_outlined,
            label: 'Atualizado em',
            value: _dateTimeFormat.format(r.updatedAt!.toLocal()),
          ),
        ],
        if (r.deletedAt != null) ...[
          _buildDivider(),
          _buildRow(
            context,
            icon: Icons.delete_outline,
            label: 'Descartado em',
            value: _dateTimeFormat.format(r.deletedAt!.toLocal()),
            valueStyle: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        _buildDivider(),
        _buildRow(
          context,
          icon: Icons.tag_outlined,
          label: 'ID',
          value: r.id,
          valueStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
                const SizedBox(height: 2),
                Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1);

  Widget _buildStatusBadge(ReceivableStatus status, ThemeData theme) {
    final color = status.badgeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
