import 'package:flutter/material.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';
import 'package:organizagrana/shared/utils/currency_input_formatter.dart';
import 'package:organizagrana/shared/utils/date_input_formatter.dart';

Future<BorderoInputItem?> showBorderoAddItem(BuildContext context) {
  return _showItemForm(context, editTarget: null);
}

Future<BorderoInputItem?> showBorderoEditItem(
  BuildContext context,
  BorderoInputItem item,
) {
  return _showItemForm(context, editTarget: item);
}

Future<BorderoInputItem?> _showItemForm(
  BuildContext context, {
  required BorderoInputItem? editTarget,
}) {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;

  if (isNarrow) {
    return showModalBottomSheet<BorderoInputItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BorderoAddItemForm(isSheet: true, editTarget: editTarget),
    );
  }

  return showDialog<BorderoInputItem>(
    context: context,
    builder: (_) => Dialog(
      child: SizedBox(
        width: 400,
        child: _BorderoAddItemForm(isSheet: false, editTarget: editTarget),
      ),
    ),
  );
}

class _BorderoAddItemForm extends StatefulWidget {
  const _BorderoAddItemForm({required this.isSheet, this.editTarget});

  final bool isSheet;
  final BorderoInputItem? editTarget;

  @override
  State<_BorderoAddItemForm> createState() => _BorderoAddItemFormState();
}

class _BorderoAddItemFormState extends State<_BorderoAddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _dueDateController = TextEditingController();

  DateTime? _selectedDueDate;

  bool get _isEditing => widget.editTarget != null;

  @override
  void initState() {
    super.initState();
    final target = widget.editTarget;
    if (target != null) {
      _valueController.text = (target.amountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _selectedDueDate = target.dueDate;
      _dueDateController.text = dateFormat.format(target.dueDate);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dueDateController.dispose();
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

    final amountCents = CurrencyInputFormatter.toCents(_valueController.text.trim());

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      BorderoInputItem(
        amountCents: amountCents,
        dueDate: _selectedDueDate!,
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
                    _isEditing ? Icons.edit_outlined : Icons.add_card_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Editar recebível' : 'Adicionar recebível',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor.';
                if (CurrencyInputFormatter.toCents(v.trim()) <= 0) return 'Valor inválido.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dueDateController,
              decoration: InputDecoration(
                labelText: 'Data de vencimento',
                hintText: 'dd/mm/aaaa',
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _pickDueDate,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [DateTextInputFormatter()],
              onChanged: (value) {
                try {
                  setState(() => _selectedDueDate = dateFormat.parseStrict(value));
                } catch (_) {
                  setState(() => _selectedDueDate = null);
                }
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a data de vencimento.';
                if (v.length < 10) return 'Data incompleta.';
                try {
                  dateFormat.parseStrict(v.trim());
                  return null;
                } catch (_) {
                  return 'Data inválida.';
                }
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEditing ? Icons.check : Icons.add, size: 18),
                    label: Text(_isEditing ? 'Salvar' : 'Adicionar'),
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
