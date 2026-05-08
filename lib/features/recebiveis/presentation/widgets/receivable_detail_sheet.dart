import 'package:flutter/material.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_update.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

Future<bool?> showReceivableDetailSheet(
  BuildContext context, {
  required String id,
  required ReceivablesService service,
}) {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;

  if (isNarrow) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.88,
        child: _ReceivableDetailSheet(id: id, service: service, isSheet: true),
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      shape: const RoundedRectangleBorder(),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 660),
        child: _ReceivableDetailSheet(id: id, service: service, isSheet: false),
      ),
    ),
  );
}

class _ReceivableDetailSheet extends StatefulWidget {
  const _ReceivableDetailSheet({
    required this.id,
    required this.service,
    required this.isSheet,
  });

  final String id;
  final ReceivablesService service;
  final bool isSheet;

  @override
  State<_ReceivableDetailSheet> createState() => _ReceivableDetailSheetState();
}

class _ReceivableDetailSheetState extends State<_ReceivableDetailSheet> {
  bool _loading = true;
  bool _saving = false;
  Receivable? _receivable;
  String? _error;
  ReceivableStatus? _selectedStatus;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.service.getById(widget.id);
      if (mounted) {
        setState(() {
          _receivable = r;
          _selectedStatus = r.status;
          _notesController.text = r.notes ?? '';
        });
      }
    } on ReceivableFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.service.update(
        widget.id,
        ReceivableUpdate(
          status: _selectedStatus!,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ReceivableFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.fromLTRB(20, widget.isSheet ? 12 : 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSheet)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detalhes do recebível',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    final keyboardPadding = widget.isSheet ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + keyboardPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: const Text('Fechar'),
          ),
          const SizedBox(width: 8),
          if (_receivable != null)
            FilledButton(
              onPressed: _saving || _selectedStatus == null ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusBar(r.status, theme, colorScheme),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
        _buildValueHighlight(r, theme, colorScheme),
        _buildField(
          theme,
          icon: Icons.calendar_today_outlined,
          label: 'Vencimento',
          value: dateFormat.format(r.dueDate),
        ),
        if (r.changeDate != null)
          _buildField(
            theme,
            icon: Icons.edit_calendar_outlined,
            label: 'Data de alteração',
            value: dateFormat.format(r.changeDate!),
          ),
        _buildField(
          theme,
          icon: Icons.hourglass_bottom_outlined,
          label: 'Dias aguardando',
          value: '${r.awaitingDays} dias',
        ),
        if (r.createdAt != null)
          _buildField(
            theme,
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: dateTimeFormat.format(r.createdAt!.toLocal()),
          ),
        if (r.updatedAt != null)
          _buildField(
            theme,
            icon: Icons.update_outlined,
            label: 'Atualizado em',
            value: dateTimeFormat.format(r.updatedAt!.toLocal()),
          ),
        if (r.deletedAt != null)
          _buildField(
            theme,
            icon: Icons.delete_outline,
            label: 'Descartado em',
            value: dateTimeFormat.format(r.deletedAt!.toLocal()),
            valueColor: colorScheme.error,
          ),
        _buildField(
          theme,
          icon: Icons.tag_outlined,
          label: 'ID',
          value: r.id,
          valueColor: colorScheme.onSurface.withValues(alpha: 0.45),
          valueFontSize: 12,
        ),
        _buildEditSection(theme, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editar',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          DropdownMenu<ReceivableStatus>(
            initialSelection: _selectedStatus,
            label: const Text('Status'),
            enabled: !_saving,
            expandedInsets: EdgeInsets.zero,
            onSelected: (v) => setState(() => _selectedStatus = v),
            dropdownMenuEntries: ReceivableStatus.values.map((s) {
              return DropdownMenuEntry(
                value: s,
                label: s.label,
                leadingIcon: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            enabled: !_saving,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: OutlineInputBorder(),
              isDense: true,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
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

  Widget _buildStatusBar(ReceivableStatus status, ThemeData theme, ColorScheme colorScheme) {
    final color = status.badgeColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        status.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
