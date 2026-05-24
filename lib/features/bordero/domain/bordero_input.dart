import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class BorderoInput {
  const BorderoInput({
    required this.changeDate,
    required this.monthlyRatePercent,
    required this.allItems,
    this.newItems,
    this.existingReceivableIds,
  });

  final DateTime changeDate;
  final double monthlyRatePercent;
  final List<BorderoInputItem> allItems;
  final List<BorderoInputItem>? newItems;
  final List<String>? existingReceivableIds;

  Map<String, dynamic> toCalculateJson() => {
        'change_date': formatDateIso(changeDate),
        'monthly_rate_percent': monthlyRatePercent,
        'receivables': allItems.map((e) => e.toJson()).toList(),
        if (existingReceivableIds != null) 'receivable_ids': existingReceivableIds,
      };

  Map<String, dynamic> toSaveJson() => {
        'change_date': formatDateIso(changeDate),
        'monthly_rate_percent': monthlyRatePercent,
        if (newItems != null) 'receivables': newItems!.map((e) => e.toJson()).toList(),
        if (existingReceivableIds != null) 'receivable_ids': existingReceivableIds,
      };
}
