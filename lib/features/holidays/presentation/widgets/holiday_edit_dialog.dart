import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/holidays/domain/calendar_day.dart';
import 'package:organizagrana/features/holidays/domain/holiday_override.dart';

sealed class HolidayEditResult {}

class HolidayEditSave extends HolidayEditResult {
  HolidayEditSave({required this.holiday, this.name});
  final bool holiday;
  final String? name;
}

class HolidayEditDelete extends HolidayEditResult {}

Future<HolidayEditResult?> showHolidayEditDialog(
  BuildContext context,
  CalendarDay day,
  HolidayOverride? existing,
) {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;

  if (isNarrow) {
    return showModalBottomSheet<HolidayEditResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _HolidayEditForm(day: day, existing: existing, isSheet: true),
    );
  }

  return showDialog<HolidayEditResult>(
    context: context,
    builder: (_) => Dialog(
      child: SizedBox(
        width: 400,
        child: _HolidayEditForm(day: day, existing: existing, isSheet: false),
      ),
    ),
  );
}

class _HolidayEditForm extends StatefulWidget {
  const _HolidayEditForm({
    required this.day,
    required this.existing,
    required this.isSheet,
  });

  final CalendarDay day;
  final HolidayOverride? existing;
  final bool isSheet;

  @override
  State<_HolidayEditForm> createState() => _HolidayEditFormState();
}

class _HolidayEditFormState extends State<_HolidayEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late bool _isHoliday;

  @override
  void initState() {
    super.initState();
    _isHoliday = widget.day.holiday;
    _nameController.text = widget.existing?.name ?? widget.day.holidayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isHoliday && !(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      HolidayEditSave(
        holiday: _isHoliday,
        name: _isHoliday ? _nameController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateLabel = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.day.date);

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
                  child: Icon(Icons.edit_calendar_outlined, size: 18, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marcar como holiday'),
              value: _isHoliday,
              onChanged: (v) => setState(() => _isHoliday = v),
            ),
            if (_isHoliday) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome do holiday',
                  hintText: 'Ex: Aniversário da cidade',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome do holiday.';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                if (widget.existing != null) ...[
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: cs.error),
                    onPressed: () => Navigator.of(context).pop(HolidayEditDelete()),
                    child: const Text('Remover'),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Salvar'),
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
