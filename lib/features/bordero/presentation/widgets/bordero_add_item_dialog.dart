import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

Future<BorderoInputItem?> showBorderoAddItem(BuildContext context) {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;

  if (isNarrow) {
    return showModalBottomSheet<BorderoInputItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _BorderoAddItemForm(isSheet: true),
    );
  }

  return showDialog<BorderoInputItem>(
    context: context,
    builder: (_) => const Dialog(
      child: SizedBox(
        width: 400,
        child: _BorderoAddItemForm(isSheet: false),
      ),
    ),
  );
}

class _BorderoAddItemForm extends StatefulWidget {
  const _BorderoAddItemForm({required this.isSheet});

  final bool isSheet;

  @override
  State<_BorderoAddItemForm> createState() => _BorderoAddItemFormState();
}

class _BorderoAddItemFormState extends State<_BorderoAddItemForm> {
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
    final awaitingDays =
        int.tryParse(_awaitingDaysController.text.trim()) ?? 1;

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
    final textTheme = Theme.of(context).textTheme;

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
                    color: colorScheme.outlineVariant,
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_card_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Adicionar recebível',
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _valueController,
              autofocus: true,
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
                final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
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
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                  ),
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

// Kept for backward compatibility — page now calls showBorderoAddItem directly.
class BorderoAddItemDialog extends StatelessWidget {
  const BorderoAddItemDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: SizedBox(
        width: 400,
        child: _BorderoAddItemForm(isSheet: false),
      ),
    );
  }
}
