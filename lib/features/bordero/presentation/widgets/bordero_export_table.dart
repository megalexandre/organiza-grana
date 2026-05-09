import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

const _headerBg = Color(0xFF4472C4);
const _headerText = Colors.white;
const _rowAltBg = Color(0xFFDCE6F1);
const _borderColor = Color(0xFFBFBFBF);
const _totalBg = Color(0xFFBDD7EE);

final _pctFormat = NumberFormat("0.0000'%'", 'pt_BR');
final _numFormat = NumberFormat('#,##0.00', 'pt_BR');

class BorderoExportTable extends StatelessWidget {
  const BorderoExportTable({
    super.key,
    required this.input,
    required this.result,
  });

  final BorderoInput input;
  final BorderoResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 6),
          _buildTable(),
          const SizedBox(height: 4),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _labelValue('Data da Troca:', dateFormat.format(input.changeDate)),
        const SizedBox(width: 40),
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
            fontSize: 13,
            color: Color(0xFF1F497D),
          ),
        ),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(fontSize: 13)),
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
      'Valor do\nIOF',
      'Valor Pago\npela troca',
      'Valor à\nReceber',
    ];

    final colWidths = [
      40.0, 90.0, 90.0, 140.0, 70.0, 80.0,
      80.0, 70.0, 60.0, 80.0, 70.0, 110.0, 100.0,
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
        ...List.generate(result.items.length, (i) {
          final item = result.items[i];
          final inputItem = input.items[i];
          final isAlt = i.isOdd;
          return _dataRow([
            '${i + 1}',
            dateFormat.format(inputItem.dueDate),
            _numFormat.format(item.value),
            '',
            '',
            '',
            '',
            '${inputItem.awaitingDays}',
            '${item.totalDays}',
            _pctFormat.format(item.interestRatePercent),
            '',
            _numFormat.format(item.interestAmount),
            _numFormat.format(item.proceeds),
          ], isAlt: isAlt);
        }),
        _totalRow(),
      ],
    );
  }

  TableRow _headerRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: _headerBg),
      children: headers.map((h) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            h,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            cells[i],
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 11),
          ),
        );
      }),
    );
  }

  TableRow _totalRow() {
    return TableRow(
      decoration: const BoxDecoration(color: _totalBg),
      children: List.generate(13, (i) {
        String text = '';
        if (i == 2) text = _numFormat.format(result.totalAmount);
        if (i == 11) text = _numFormat.format(result.totalInterestAmount);
        if (i == 12) text = _numFormat.format(result.totalProceeds);
        final isNumeric = i == 0 || i >= 7;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: Text(
            text,
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Prazo médio: ${_numFormat.format(result.averageDays)} dias',
      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    );
  }
}
