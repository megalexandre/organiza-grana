import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

const _headerBg = Color(0xFF4472C4);
const _headerText = Colors.white;
const _rowAltBg = Color(0xFFDCE6F1);
const _borderColor = Color(0xFFBFBFBF);
const _totalBg = Color(0xFFBDD7EE);

final _numFormat = NumberFormat('#,##0.00', 'pt_BR');
final _pctFormat = NumberFormat('#,##0.0000', 'pt_BR');

class BorderoExportTable extends StatelessWidget {
  const BorderoExportTable({
    super.key,
    required this.input,
    required this.savedBordero,
  });

  final BorderoInput input;
  final SavedBordero savedBordero;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          _buildTable(),
          const SizedBox(height: 3),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _labelValue('Data da Troca:', dateFormat.format(input.changeDate)),
        const SizedBox(width: 32),
        _labelValue(
          'Juros ao Mês:',
          '${_numFormat.format(input.monthlyRatePercent)}%',
        ),
      ],
    );
  }

  Widget _labelValue(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Color(0xFF1F497D),
          ),
        ),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTable() {
    final headers = [
      'Seq',
      'Data\nVencimentos',
      'Valor\nCheque',
      'Titular do\nCheque',
      'Nº ou\nBanco',
      'Nº da\nAgência',
      'Nº do\nCheque',
      'Dias p/\nComp.',
      'Qtde\ndias',
      'Total dos\nJuros',
      'Valor Pago\npela troca',
      'Valor à\nReceber',
    ];

    final colWidths = [
      30.0, 72.0, 76.0, 100.0, 52.0, 62.0,
      62.0, 50.0, 50.0, 72.0, 88.0, 82.0,
    ];

    return Table(
      border: TableBorder.all(color: _borderColor, width: 0.5),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        for (var i = 0; i < colWidths.length; i++)
          i: FixedColumnWidth(colWidths[i]),
      },
      children: [
        _headerRow(headers),
        ...List.generate(input.allItems.length, (i) {
          final item = input.allItems[i];
          final isAlt = i.isOdd;
          return _dataRow(_rowCells(item, input.awaitingDays), isAlt: isAlt);
        }),
        _totalRow(),
      ],
    );
  }

  List<String> _rowCells(BorderoInputItem item, int awaitingDays) {
    final interest = item.interestAmountCents;
    final proceeds = item.proceedsCents;
    final totalDays = item.totalDays;
    final rate = (interest != null && item.amountCents > 0)
        ? '${_pctFormat.format((interest / item.amountCents) * 100)}%'
        : '';

    return [
      '',
      dateFormat.format(item.dueDate),
      _numFormat.format(item.value),
      '', '', '', '',
      '$awaitingDays',
      totalDays != null ? '$totalDays' : '',
      rate,
      interest != null ? _numFormat.format(interest / 100) : '',
      proceeds != null ? _numFormat.format(proceeds / 100) : '',
    ];
  }

  TableRow _headerRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: _headerBg),
      children: headers.map((h) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(
            h,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: _headerText,
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _dataRow(List<String> cells, {required bool isAlt}) {
    final bg = isAlt ? _rowAltBg : Colors.white;
    return TableRow(
      decoration: BoxDecoration(color: bg),
      children: List.generate(cells.length, (i) {
        final isNumeric = i == 0 || i >= 7;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          child: Text(
            cells[i],
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 10),
          ),
        );
      }),
    );
  }

  TableRow _totalRow() {
    return TableRow(
      decoration: const BoxDecoration(color: _totalBg),
      children: List.generate(12, (i) {
        String text = '';
        if (i == 2) text = _numFormat.format(savedBordero.totalAmount);
        if (i == 10) text = _numFormat.format(savedBordero.totalInterestAmount);
        if (i == 11) text = _numFormat.format(savedBordero.totalProceeds);
        final isNumeric = i == 0 || i >= 7;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(
            text,
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Prazo médio: ${_numFormat.format(savedBordero.averageDays)} dias',
      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
    );
  }
}
