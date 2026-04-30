import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final dateFormat = DateFormat('dd/MM/yyyy');
final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

String formatDateIso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}'
    '-${date.month.toString().padLeft(2, '0')}'
    '-${date.day.toString().padLeft(2, '0')}';
