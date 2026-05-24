import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/bordero/data/bordero_export_service.dart' show exportBorderoToCsv;
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_add_item_dialog.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_export_table.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_item_card.dart';
import 'package:organizagrana/features/bordero/presentation/widgets/bordero_summary_panel.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';
import 'package:organizagrana/shared/utils/date_input_formatter.dart';
import 'package:organizagrana/shared/layout/page_content_constraint.dart';
import 'package:organizagrana/shared/utils/web_download.dart';
import 'package:organizagrana/shared/utils/widget_capture.dart';

class BorderoPage extends StatefulWidget {
  const BorderoPage({
    super.key,
    required this.service,
    required this.receivablesService,
    this.initialBorderoId,
  });

  final BorderoService service;
  final ReceivablesService receivablesService;
  final String? initialBorderoId;

  @override
  State<BorderoPage> createState() => _BorderoPageState();
}

class _BorderoPageState extends State<BorderoPage> {
  final _formKey = GlobalKey<FormState>();
  final _changeDateController = TextEditingController();
  final _rateController = TextEditingController();

  DateTime _changeDate = DateTime.now();
  final List<BorderoInputItem> _items = [];
  final List<String?> _receivableIds = [];
  final Set<String> _preloadedReceivableIds = {};
  BorderoResult? _result;
  String? _savedBorderoId;
  bool _loading = false;
  bool _saving = false;
  bool _loadingInitial = false;
  String? _errorMessage;
  bool _paramsConfirmed = false;

  @override
  void initState() {
    super.initState();
    _changeDateController.text = dateFormat.format(_changeDate);
    if (widget.initialBorderoId != null) {
      _loadingInitial = true;
      _loadExisting(widget.initialBorderoId!);
    }
  }

  Future<void> _loadExisting(String borderoId) async {
    setState(() {
      _loadingInitial = true;
      _errorMessage = null;
    });
    try {
      final bordero = await widget.service.getById(borderoId);
      if (!mounted) return;
      final receivablesResult = await widget.receivablesService.listPage(
        page: 1,
        perPage: 500,
        borderoId: borderoId,
      );
      if (!mounted) return;
      final receivables = receivablesResult.items;
      setState(() {
        _savedBorderoId = bordero.id;
        _changeDate = bordero.changeDate;
        _changeDateController.text = dateFormat.format(bordero.changeDate);
        _rateController.text =
            bordero.monthlyRatePercent.toStringAsFixed(2).replaceAll('.', ',');
        _items.addAll(receivables.map((r) => BorderoInputItem(
              amountCents: r.amountCents,
              dueDate: r.dueDate,
              awaitingDays: r.awaitingDays,
            )));
        _receivableIds.addAll(receivables.map((r) => r.id));
        _preloadedReceivableIds.addAll(receivables.map((r) => r.id));
        _paramsConfirmed = true;
      });
      if (_items.isNotEmpty) await _calculate();
    } on BorderoFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } on ReceivableFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Erro ao carregar borderô: $e');
    } finally {
      if (mounted) setState(() => _loadingInitial = false);
    }
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

  void _confirmParams() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _paramsConfirmed = true);
  }

  Future<void> _editParams() async {
    final ids = _receivableIds
        .whereType<String>()
        .where((id) => !_preloadedReceivableIds.contains(id))
        .toList();
    await Future.wait(ids.map((id) => widget.receivablesService.delete(id).catchError((_) {})));
    setState(() {
      _paramsConfirmed = false;
      _result = null;
      _errorMessage = null;
      _items.clear();
      _receivableIds.clear();
      _preloadedReceivableIds.clear();
    });
  }

  Future<void> _save() async {
    if (_savedBorderoId == null || _receivableIds.isEmpty) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await Future.wait(
        _receivableIds
            .whereType<String>()
            .map((id) => widget.receivablesService.changeStatus(id, ReceivableStatus.awaiting)),
      );
      if (mounted) context.pop(true);
    } on ReceivableFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openAddItemDialog() async {
    final item = await showBorderoAddItem(context);
    if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    if (item == null) return;

    setState(() {
      _errorMessage = null;
      _items.add(item);
      _receivableIds.add(null);
    });

    await _calculate();

    if (!mounted) return;

    // Auto-salvar ou atualizar o borderô — recebíveis são criados inline pelo servidor
    try {
      if (_savedBorderoId == null) {
        final saved = await widget.service.save(_buildInput());
        if (mounted) {
          setState(() {
            _savedBorderoId = saved.id;
            _syncReceivableIds(saved);
          });
        }
      } else {
        final saved = await widget.service.update(_savedBorderoId!, _buildInput());
        if (mounted) setState(() => _syncReceivableIds(saved));
      }
    } on BorderoFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    }
  }

  void _syncReceivableIds(SavedBordero saved) {
    final serverItems = saved.items ?? [];
    for (int i = 0; i < serverItems.length && i < _receivableIds.length; i++) {
      _receivableIds[i] = serverItems[i].id;
    }
  }

  Future<void> _removeItem(int index) async {
    final receivableId = index < _receivableIds.length ? _receivableIds[index] : null;

    setState(() {
      _items.removeAt(index);
      if (index < _receivableIds.length) _receivableIds.removeAt(index);
      _errorMessage = null;
    });

    if (receivableId != null && !_preloadedReceivableIds.contains(receivableId)) {
      widget.receivablesService.delete(receivableId).catchError((_) {});
    }

    if (_items.isEmpty) {
      setState(() => _result = null);
      return;
    }

    await _calculate();

    if (_savedBorderoId != null && mounted) {
      () async {
        try {
          await widget.service.update(_savedBorderoId!, _buildInput());
        } catch (_) {}
      }();
    }
  }

  BorderoInput _buildInput() {
    final rate =
        double.tryParse(_rateController.text.trim().replaceAll(',', '.')) ?? 0;
    final existingIds = <String>[];
    final newItems = <BorderoInputItem>[];
    for (int i = 0; i < _items.length; i++) {
      final id = i < _receivableIds.length ? _receivableIds[i] : null;
      if (id != null) {
        existingIds.add(id);
      } else {
        newItems.add(_items[i]);
      }
    }
    return BorderoInput(
      changeDate: _changeDate,
      monthlyRatePercent: rate,
      allItems: List.unmodifiable(_items),
      newItems: newItems.isEmpty ? null : List.unmodifiable(newItems),
      existingReceivableIds: existingIds.isEmpty ? null : List.unmodifiable(existingIds),
    );
  }

  void _exportToCsv() {
    if (_result == null) return;
    try {
      final bytes = exportBorderoToCsv(_buildInput(), _result!);
      final filename =
          'bordero_${DateFormat('yyyy-MM-dd').format(_changeDate)}.csv';
      downloadFile(bytes, filename, 'text/csv;charset=utf-8');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e')),
        );
      }
    }
  }

  Future<void> _exportToImage() async {
    if (_result == null) return;
    try {
      final input = _buildInput();
      final bytes = await captureWidgetAsPng(
        BorderoExportTable(input: input, result: _result!),
      );
      final filename =
          'bordero_${DateFormat('yyyy-MM-dd').format(_changeDate)}.png';
      downloadFile(bytes, filename, 'image/png');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar imagem: $e')),
        );
      }
    }
  }

  Future<void> _calculate() async {
    if (_items.isEmpty) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await widget.service.calculate(_buildInput());
      if (mounted) setState(() => _result = result);
    } on BorderoFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInitial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && !_paramsConfirmed && widget.initialBorderoId != null) {
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _loadExisting(widget.initialBorderoId!),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (_paramsConfirmed) _buildCompactParams(context),
          if (_paramsConfirmed && _result != null)
            BorderoSummaryPanel(result: _result!, itemCount: _items.length),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isNarrow ? 16 : 24,
                    isNarrow ? 16 : 24,
                    isNarrow ? 16 : 24,
                    96 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: PageContentConstraint(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_paramsConfirmed) ...[
                              _buildParamsSection(context, isNarrow),
                              const SizedBox(height: 20),
                              _buildConfirmButton(),
                            ],
                            if (_paramsConfirmed) ...[
                              _buildItemsSection(context),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _errorMessage != null
                                    ? Padding(
                                        key: const ValueKey('error'),
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildError(context),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('no-error'),
                                      ),
                              ),
                              if (_loading)
                                const LinearProgressIndicator(minHeight: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOut,
                                child: _result != null
                                    ? Padding(
                                        key: ValueKey(_result),
                                        padding: const EdgeInsets.only(top: 16),
                                        child: _buildResultSection(
                                          context,
                                          _result!,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('no-result'),
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _paramsConfirmed
          ? FloatingActionButton.extended(
              onPressed: _openAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('Recebível'),
              tooltip: 'Adicionar recebível',
            )
          : null,
    );
  }

  Widget _buildCompactParams(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_outlined, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Troca: ${dateFormat.format(_changeDate)}  |  Juros: ${_rateController.text}% a.m.',
              style: textTheme.bodySmall,
            ),
          ),
          if (widget.initialBorderoId == null)
            TextButton(
              onPressed: _editParams,
              child: const Text('Editar'),
            ),
        ],
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

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _confirmParams,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Confirmar e adicionar recebíveis'),
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
        suffixIcon: IconButton(
          icon: Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: _pickChangeDate,
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [DateTextInputFormatter()],
      onChanged: (value) {
        if (value.length == 10) {
          try {
            setState(() => _changeDate = dateFormat.parseStrict(value));
          } catch (_) {}
        }
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe a data.';
        if (v.length < 10) return 'Data incompleta.';
        try {
          dateFormat.parseStrict(v.trim());
          return null;
        } catch (_) {
          return 'Data inválida.';
        }
      },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  itemBuilder: (_, index) => BorderoItemCard(
                    key: ObjectKey(_items[index]),
                    index: index,
                    inputItem: _items[index],
                    resultItem: _result?.items[index],
                    onRemove: _preloadedReceivableIds.contains(_receivableIds[index])
                        ? null
                        : () => _removeItem(index),
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
        border: Border.all(color: colorScheme.outlineVariant),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportToImage,
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Exportar Imagem'),
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.table_chart_outlined, size: 16),
                label: const Text('Exportar CSV'),
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 16),
            label: const Text('Salvar'),
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
