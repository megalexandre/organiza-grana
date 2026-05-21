enum ReceivableSortField { dueDate, amount, createdAt }

enum ReceivableSortDirection { asc, desc }

extension ReceivableSortFieldApi on ReceivableSortField {
  String toApiValue() => switch (this) {
        ReceivableSortField.dueDate => 'due_date',
        ReceivableSortField.amount => 'amount',
        ReceivableSortField.createdAt => 'created_at',
      };
}

extension ReceivableSortDirectionApi on ReceivableSortDirection {
  String toApiValue() => switch (this) {
        ReceivableSortDirection.asc => 'asc',
        ReceivableSortDirection.desc => 'desc',
      };
}
