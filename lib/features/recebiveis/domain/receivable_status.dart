import 'package:flutter/material.dart';
import 'package:organizagrana/app/app_theme.dart';

enum ReceivableStatus {
  draft(-1, 'Rascunho'),
  awaiting(0, 'Aguardando'),
  toDeposit(1, 'A depositar'),
  deposited(2, 'Depositado'),
  returned(3, 'Retornado'),
  overdue(4, 'Vencido'),
  paid(5, 'Pago');

  const ReceivableStatus(this.value, this.label);

  final int value;
  final String label;

  Color colorFor(Brightness brightness) => switch (brightness) {
        Brightness.dark => switch (this) {
          ReceivableStatus.draft     => AppColors.statusDraft,
          ReceivableStatus.awaiting  => AppColors.statusAwaiting,
          ReceivableStatus.toDeposit => AppColors.statusToDeposit,
          ReceivableStatus.deposited => AppColors.statusDeposited,
          ReceivableStatus.returned  => AppColors.statusReturned,
          ReceivableStatus.overdue   => AppColors.statusOverdue,
          ReceivableStatus.paid      => AppColors.statusPaid,
        },
        Brightness.light => switch (this) {
          ReceivableStatus.draft     => AcalLightColors.statusDraft,
          ReceivableStatus.awaiting  => AcalLightColors.statusAwaiting,
          ReceivableStatus.toDeposit => AcalLightColors.statusToDeposit,
          ReceivableStatus.deposited => AcalLightColors.statusDeposited,
          ReceivableStatus.returned  => AcalLightColors.statusReturned,
          ReceivableStatus.overdue   => AcalLightColors.statusOverdue,
          ReceivableStatus.paid      => AcalLightColors.statusPaid,
        },
      };

  bool get canReceive =>
      this == awaiting || this == toDeposit || this == deposited;

  ReceivableStatus? get next {
    final nextVal = value + 1;
    return ReceivableStatus.values.where((s) => s.value == nextVal).firstOrNull;
  }

  ReceivableStatus? get previous {
    if (this == draft || this == awaiting) return null;
    final prevVal = value - 1;
    return ReceivableStatus.values.where((s) => s.value == prevVal).firstOrNull;
  }

  static ReceivableStatus? fromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) {
      return ReceivableStatus.values.where((s) => s.value == raw).firstOrNull;
    }
    final str = raw.toString().toLowerCase();
    return switch (str) {
      'draft'      => ReceivableStatus.draft,
      'awaiting'   => ReceivableStatus.awaiting,
      'to_deposit' => ReceivableStatus.toDeposit,
      'deposited'  => ReceivableStatus.deposited,
      'returned'   => ReceivableStatus.returned,
      'overdue'    => ReceivableStatus.overdue,
      'paid'       => ReceivableStatus.paid,
      _ => null,
    };
  }

  String toJson() => switch (this) {
        ReceivableStatus.draft     => 'draft',
        ReceivableStatus.awaiting  => 'awaiting',
        ReceivableStatus.toDeposit => 'to_deposit',
        ReceivableStatus.deposited => 'deposited',
        ReceivableStatus.returned  => 'returned',
        ReceivableStatus.overdue   => 'overdue',
        ReceivableStatus.paid      => 'paid',
      };
}
