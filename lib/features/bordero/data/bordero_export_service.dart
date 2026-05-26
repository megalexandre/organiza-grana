import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

final _numFormat = NumberFormat('#,##0.00', 'pt_BR');

Uint8List exportBorderoToCsv(BorderoInput input, SavedBordero savedBordero) {
  final rows = <List<String>>[
    ['Data da Troca', dateFormat.format(input.changeDate)],
    ['Juros ao Mês', '${_numFormat.format(input.monthlyRatePercent)}%'],
    [],
    [
      'Seq', 'Data Vencimentos', 'Valor Cheque', 'Titular do Cheque',
      'Nº ou Banco', 'Nº da Agência', 'Nº do Cheque', 'Dias p/ Comp.',
      'Qtde dias', 'Total dos Juros', 'Valor do IOF',
      'Valor Pago pela troca', 'Valor à Receber',
    ],
    ...List.generate(input.allItems.length, (i) {
      final inputItem = input.allItems[i];
      return [
        '${i + 1}',
        dateFormat.format(inputItem.dueDate),
        _numFormat.format(inputItem.value),
        '', '', '', '',
        '${input.awaitingDays}',
        '', '', '', '', '',
      ];
    }),
    [
      '', '', _numFormat.format(savedBordero.totalAmount),
      '', '', '', '', '', '', '', '',
      _numFormat.format(savedBordero.totalInterestAmount),
      _numFormat.format(savedBordero.totalProceeds),
    ],
    [],
    ['', '', '', '', '', '', '', 'Prazo médio:', '${_numFormat.format(savedBordero.averageDays)} dias'],
  ];

  final buffer = StringBuffer();
  for (final row in rows) {
    buffer.writeln(row.map(_escapeCsv).join(';'));
  }

  // BOM UTF-8 para compatibilidade com Excel no Windows
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(buffer.toString())]);
}

String _escapeCsv(String value) {
  if (value.contains(';') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

const _blue = ExcelColor.blue;
final _headerBg = ExcelColor.fromHexString('#BDD7EE');
final _altRowBg = ExcelColor.fromHexString('#DCE6F1');
final _totalBg = ExcelColor.fromHexString('#BDD7EE');

Uint8List exportBorderoToExcel(BorderoInput input, SavedBordero savedBordero) {
  final excel = Excel.createExcel();
  excel.rename('Sheet1', 'Borderô');
  final sheet = excel['Borderô'];

  // ── Linha 0: parâmetros ──────────────────────────────────────────────────
  _setCell(sheet, 0, 0, 'Data da Troca:', bold: true, color: _blue);
  _setCell(sheet, 0, 1, dateFormat.format(input.changeDate));
  _setCell(sheet, 0, 4, 'Juros ao Mês:', bold: true, color: _blue);
  _setCell(
    sheet,
    0,
    5,
    '${_numFormat.format(input.monthlyRatePercent)}%',
  );

  // ── Linha 2: cabeçalhos das colunas ─────────────────────────────────────
  final headers = [
    'Seq', 'Data Vencimentos', 'Valor Cheque', 'Titular do Cheque',
    'Nº ou Banco', 'Nº da Agência', 'Nº do Cheque', 'Dias p/ Comp.',
    'Qtde dias', 'Total dos Juros', 'Valor do IOF',
    'Valor Pago pela troca', 'Valor à Receber',
  ];
  for (var c = 0; c < headers.length; c++) {
    _setCell(
      sheet, 2, c, headers[c],
      bold: true,
      align: HorizontalAlign.Center,
      bg: _headerBg,
    );
  }

  // ── Linhas de dados ──────────────────────────────────────────────────────
  for (var i = 0; i < input.allItems.length; i++) {
    final r = i + 3;
    final inputItem = input.allItems[i];
    final bg = i.isOdd ? _altRowBg : null;

    _setCell(sheet, r, 0, i + 1, align: HorizontalAlign.Right, bg: bg);
    _setCell(sheet, r, 1, dateFormat.format(inputItem.dueDate), bg: bg);
    _setCell(
      sheet, r, 2, _numFormat.format(inputItem.value),
      align: HorizontalAlign.Right, bg: bg,
    );
    _setCell(sheet, r, 3, '', bg: bg);
    _setCell(sheet, r, 4, '', bg: bg);
    _setCell(sheet, r, 5, '', bg: bg);
    _setCell(sheet, r, 6, '', bg: bg);
    _setCell(
      sheet, r, 7, input.awaitingDays,
      align: HorizontalAlign.Right, bg: bg,
    );
    _setCell(sheet, r, 8, '', bg: bg);
    _setCell(sheet, r, 9, '', bg: bg);
    _setCell(sheet, r, 10, '', bg: bg);
    _setCell(sheet, r, 11, '', bg: bg);
    _setCell(sheet, r, 12, '', bg: bg);
  }

  // ── Linha de totais ──────────────────────────────────────────────────────
  final totalRow = input.allItems.length + 3;
  for (var c = 0; c < 13; c++) {
    String text = '';
    if (c == 2) text = _numFormat.format(savedBordero.totalAmount);
    if (c == 11) text = _numFormat.format(savedBordero.totalInterestAmount);
    if (c == 12) text = _numFormat.format(savedBordero.totalProceeds);
    _setCell(
      sheet, totalRow, c, text,
      bold: true,
      align: HorizontalAlign.Right,
      bg: _totalBg,
    );
  }

  // ── Prazo médio ──────────────────────────────────────────────────────────
  final avgRow = totalRow + 1;
  _setCell(sheet, avgRow, 7, 'Prazo médio:', bold: true);
  _setCell(
    sheet, avgRow, 8,
    '${_numFormat.format(savedBordero.averageDays)} dias',
    align: HorizontalAlign.Right,
  );

  // ── Larguras das colunas ─────────────────────────────────────────────────
  const widths = [6.0, 14.0, 14.0, 22.0, 12.0, 14.0, 14.0, 14.0, 12.0, 14.0, 14.0, 20.0, 16.0];
  for (var c = 0; c < widths.length; c++) {
    sheet.setColumnWidth(c, widths[c]);
  }

  return Uint8List.fromList(excel.encode()!);
}

void _setCell(
  Sheet sheet,
  int row,
  int col,
  Object value, {
  bool bold = false,
  HorizontalAlign? align,
  ExcelColor? bg,
  ExcelColor? color,
}) {
  final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  cell.value = switch (value) {
    final int v => IntCellValue(v),
    final double v => DoubleCellValue(v),
    final String v => TextCellValue(v),
    _ => TextCellValue(value.toString()),
  };
  var style = CellStyle(bold: bold);
  if (align != null) style = style.copyWith(horizontalAlignVal: align);
  if (bg != null) style = style.copyWith(backgroundColorHexVal: bg);
  if (color != null) style = style.copyWith(fontColorHexVal: color);
  cell.cellStyle = style;
}
