import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

Future<bool?> showAddReceivableSheet(
  BuildContext context, {
  required ReceivablesService service,
}) {
  return _showSheet(context, service: service, editTarget: null);
}

Future<bool?> showEditReceivableDraftSheet(
  BuildContext context, {
  required ReceivablesService service,
  required Receivable receivable,
}) {
  return _showSheet(context, service: service, editTarget: receivable);
}

Future<bool?> _showSheet(
  BuildContext context, {
  required ReceivablesService service,
  required Receivable? editTarget,
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
      builder: (_) => _AddReceivableForm(service: service, isSheet: true, editTarget: editTarget),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      child: SizedBox(
        width: 400,
        child: _AddReceivableForm(service: service, isSheet: false, editTarget: editTarget),
      ),
    ),
  );
}

class _AddReceivableForm extends StatefulWidget {
  const _AddReceivableForm({required this.service, required this.isSheet, this.editTarget});

  final ReceivablesService service;
  final bool isSheet;
  final Receivable? editTarget;

  @override
  State<_AddReceivableForm> createState() => _AddReceivableFormState();
}

class _AddReceivableFormState extends State<_AddReceivableForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _changeDateController = TextEditingController();
  final _dueDateController = TextEditingController();

  DateTime? _selectedChangeDate;
  DateTime? _selectedDueDate;
  bool _loading = false;

  bool get _isEditing => widget.editTarget != null;

  @override
  void initState() {
    super.initState();
    final target = widget.editTarget;
    if (target != null) {
      _valueController.text = (target.amountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _selectedDueDate = target.dueDate;
      _dueDateController.text = dateFormat.format(target.dueDate);
      _selectedChangeDate = target.changeDate;
      if (target.changeDate != null) {
        _changeDateController.text = dateFormat.format(target.changeDate!);
      }
    } else {
      _selectedChangeDate = DateTime.now();
      _changeDateController.text = dateFormat.format(_selectedChangeDate!);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _changeDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickChangeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedChangeDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        _selectedChangeDate = picked;
        _changeDateController.text = dateFormat.format(picked);
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = dateFormat.format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rawValue = _valueController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(rawValue);
    if (value == null || value <= 0) return;

    final amountCents = (value * 100).round();

    setState(() => _loading = true);

    final draft = ReceivableDraft(
      amountCents: amountCents,
      dueDate: _selectedDueDate!,
      changeDate: _selectedChangeDate,
      status: ReceivableStatus.draft,
    );
    try {
      if (_isEditing) {
        await widget.service.updateDraft(widget.editTarget!.id, draft);
      } else {
        await widget.service.create(draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ReceivableFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        widget.isSheet ? 8 : 24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isSheet)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                    size: 18,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Editar rascunho' : 'Novo recebível',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: '0,00',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor.';
                final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Valor inválido.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _changeDateController,
              decoration: InputDecoration(
                labelText: 'Data da troca',
                hintText: 'dd/mm/aaaa',
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
              readOnly: true,
              onTap: _pickChangeDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dueDateController,
              decoration: InputDecoration(
                labelText: 'Data de vencimento',
                hintText: 'dd/mm/aaaa',
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
              readOnly: true,
              onTap: _pickDueDate,
              validator: (v) {
                if (_selectedDueDate == null) return 'Selecione a data de vencimento.';
                return null;
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return widget.isSheet ? SingleChildScrollView(child: content) : content;
  }
}
