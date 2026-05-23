enum BorderoSortField { changeDate, createdAt, totalAmount, averageDays }

enum BorderoSortDirection { asc, desc }

extension BorderoSortFieldApi on BorderoSortField {
  String toApiValue() => switch (this) {
        BorderoSortField.changeDate => 'change_date',
        BorderoSortField.createdAt => 'created_at',
        BorderoSortField.totalAmount => 'total_amount_cents',
        BorderoSortField.averageDays => 'average_days',
      };
}

extension BorderoSortDirectionApi on BorderoSortDirection {
  String toApiValue() => switch (this) {
        BorderoSortDirection.asc => 'asc',
        BorderoSortDirection.desc => 'desc',
      };
}
