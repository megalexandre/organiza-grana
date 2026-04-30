import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoInput {
  const BorderoInput({
    required this.changeDate,
    required this.monthlyRatePercent,
    required this.items,
  });

  final DateTime changeDate;
  final double monthlyRatePercent;
  final List<BorderoInputItem> items;

  Map<String, dynamic> toJson() => {
        'change_date': formatDateIso(changeDate),
        'monthly_rate_percent': monthlyRatePercent,
        'receivables': items.map((e) => e.toJson()).toList(),
      };
}
