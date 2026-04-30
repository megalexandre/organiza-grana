import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class AddReceivableDialog extends StatefulWidget {
  const AddReceivableDialog({super.key, required this.service});

  final ReceivablesService service;

  @override
  State<AddReceivableDialog> createState() => _AddReceivableDialogState();
}

class _AddReceivableDialogState extends State<AddReceivableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _changeDateController = TextEditingController();
  final _dueDateController = TextEditingController();

  DateTime? _selectedChangeDate;
  DateTime? _selectedDueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedChangeDate = DateTime.now();
    _changeDateController.text = dateFormat.format(_selectedChangeDate!);
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
    );
    try {
      await widget.service.create(draft);
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(
        'Novo recebível',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    color: colorScheme.onSurfaceVariant,
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
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                readOnly: true,
                onTap: _pickDueDate,
                validator: (v) {
                  if (_selectedDueDate == null) return 'Selecione a data de vencimento.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
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
    );
  }
}
