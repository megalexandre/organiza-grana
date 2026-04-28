import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/shared/utils/app_formats.dart';

class ReceivableCard extends StatelessWidget {
  const ReceivableCard({
    super.key,
    required this.receivable,
    this.onDetails,
    this.onReceive,
  });

  final Receivable receivable;
  final VoidCallback? onDetails;
  final VoidCallback? onReceive;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recebível', style: theme.textTheme.titleMedium),
                  _buildStatusBadge(receivable.status, theme),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Valor: ${currencyFormat.format(receivable.value)}',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                'Vencimento: ${_dateFormat.format(receivable.receiptDate)}',
                style: theme.textTheme.bodyMedium,
              ),
              if (onReceive != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onReceive,
                  child: const Text('Marcar como recebido'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReceivableStatus? status, ThemeData theme) {
    final color = status?.badgeColor ?? Colors.grey;
    final label = status?.label ?? 'Desconhecido';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
