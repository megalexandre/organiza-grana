import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_add_item_dialog.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_item_tile.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_result_card.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_summary_panel.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoPage extends StatefulWidget {
  const BorderoPage({super.key, required this.service});

  final BorderoService service;

  @override
  State<BorderoPage> createState() => _BorderoPageState();
}

class _BorderoPageState extends State<BorderoPage> {
  final _formKey = GlobalKey<FormState>();
  final _changeDateController = TextEditingController();
  final _rateController = TextEditingController();

  DateTime _changeDate = DateTime.now().add(const Duration(days: 2));
  final List<BorderoInputItem> _items = [];
  BorderoResult? _result;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _changeDateController.text = dateFormat.format(_changeDate);
  }

  @override
  void dispose() {
    _changeDateController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickChangeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _changeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        _changeDate = picked;
        _changeDateController.text = dateFormat.format(picked);
      });
    }
  }

  Future<void> _openAddItemDialog() async {
    final item = await showBorderoAddItem(context);
    if (item != null) {
      setState(() {
        _items.add(item);
        _result = null;
        _errorMessage = null;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _calculate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos um recebível antes de calcular.'),
        ),
      );
      return;
    }

    final rate =
        double.tryParse(_rateController.text.trim().replaceAll(',', '.')) ?? 0;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await widget.service.calculate(
        BorderoInput(
          changeDate: _changeDate,
          monthlyRatePercent: rate,
          items: List.unmodifiable(_items),
        ),
      );
      if (mounted) setState(() => _result = result);
    } on BorderoFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isNarrow ? 16 : 24,
              isNarrow ? 16 : 24,
              isNarrow ? 16 : 24,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildParamsSection(context, isNarrow),
                      const SizedBox(height: 24),
                      _buildItemsSection(context),
                      const SizedBox(height: 20),
                      _buildCalculateButton(context),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _errorMessage != null
                            ? Padding(
                                key: const ValueKey('error'),
                                padding: const EdgeInsets.only(top: 16),
                                child: _buildError(context),
                              )
                            : const SizedBox.shrink(key: ValueKey('no-error')),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        child: _result != null
                            ? Padding(
                                key: ValueKey(_result),
                                padding: const EdgeInsets.only(top: 32),
                                child: _buildResultSection(context, _result!),
                              )
                            : const SizedBox.shrink(key: ValueKey('no-result')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Recebível'),
        tooltip: 'Adicionar recebível',
      ),
    );
  }

  Widget _buildParamsSection(BuildContext context, bool isNarrow) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Icons.tune_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Parâmetros',
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isNarrow)
              Column(
                children: [
                  _buildDateField(context),
                  const SizedBox(height: 16),
                  _buildRateField(),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildDateField(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRateField()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
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
    );
  }

  Widget _buildRateField() {
    return TextFormField(
      controller: _rateController,
      decoration: const InputDecoration(
        labelText: 'Juros ao mês',
        hintText: '2,00',
        suffixText: '%',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe a taxa.';
        final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) return 'Taxa inválida.';
        return null;
      },
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recebíveis',
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_items.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _items.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  key: const ValueKey('list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => BorderoItemTile(
                    key: ObjectKey(_items[index]),
                    item: _items[index],
                    onRemove: () => _removeItem(index),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum recebível adicionado',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use o botão + para adicionar',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _loading ? null : _calculate,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate_outlined),
        label: Text(_loading ? 'Calculando…' : 'Calcular Borderô'),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, BorderoResult result) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultado',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) => BorderoResultCard(
            index: index,
            item: result.items[index],
          ),
        ),
        const SizedBox(height: 16),
        BorderoSummaryPanel(result: result),
      ],
    );
  }
}
