enum ReceivableSortField { dueDate, amount }

enum ReceivableSortDirection { asc, desc }

extension ReceivableSortFieldApi on ReceivableSortField {
  String toApiValue() => switch (this) {
        ReceivableSortField.dueDate => 'due_date',
        ReceivableSortField.amount => 'amount',
      };
}

extension ReceivableSortDirectionApi on ReceivableSortDirection {
  String toApiValue() => switch (this) {
        ReceivableSortDirection.asc => 'asc',
        ReceivableSortDirection.desc => 'desc',
      };
}
