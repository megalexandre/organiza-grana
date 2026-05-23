import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoInput {
  const BorderoInput({
    required this.changeDate,
    required this.monthlyRatePercent,
    required this.items,
    this.receivableIds,
  });

  final DateTime changeDate;
  final double monthlyRatePercent;
  final List<BorderoInputItem> items;
  final List<String>? receivableIds;

  Map<String, dynamic> toJson() => {
        'change_date': formatDateIso(changeDate),
        'monthly_rate_percent': monthlyRatePercent,
        'receivables': items.map((e) => e.toJson()).toList(),
        if (receivableIds != null) 'receivable_ids': receivableIds,
      };
}
