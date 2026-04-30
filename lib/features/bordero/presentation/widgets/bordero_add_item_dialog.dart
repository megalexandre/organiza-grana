import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoAddItemDialog extends StatefulWidget {
  const BorderoAddItemDialog({super.key});

  @override
  State<BorderoAddItemDialog> createState() => _BorderoAddItemDialogState();
}

class _BorderoAddItemDialogState extends State<BorderoAddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _awaitingDaysController = TextEditingController(text: '1');

  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _valueController.dispose();
    _dueDateController.dispose();
    _awaitingDaysController.dispose();
    super.dispose();
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rawValue = _valueController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(rawValue) ?? 0;
    final amountCents = (value * 100).round();
    final awaitingDays = int.tryParse(_awaitingDaysController.text.trim()) ?? 1;

    Navigator.of(context).pop(
      BorderoInputItem(
        amountCents: amountCents,
        dueDate: _selectedDueDate!,
        awaitingDays: awaitingDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: const Text('Adicionar recebível'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor.';
                  final parsed =
                      double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Valor inválido.';
                  return null;
                },
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
                validator: (_) {
                  if (_selectedDueDate == null) {
                    return 'Selecione a data de vencimento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _awaitingDaysController,
                decoration: const InputDecoration(
                  labelText: 'Dias em espera',
                  hintText: '1',
                  suffixText: 'dias',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Informe um número válido.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
