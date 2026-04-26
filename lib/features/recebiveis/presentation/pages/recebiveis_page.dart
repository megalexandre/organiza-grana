import 'package:flutter/material.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/add_receivable_dialog.dart';

class RecebiveisPage extends StatefulWidget {
  const RecebiveisPage({super.key});

  @override
  State<RecebiveisPage> createState() => _RecebiveisPageState();
}

class _RecebiveisPageState extends State<RecebiveisPage> {
  late final ReceivablesService _service;

  @override
  void initState() {
    super.initState();
    _service = ReceivablesService(AuthStorage());
  }

  Future<void> _openAddDialog() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddReceivableDialog(service: _service),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recebível adicionado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recebíveis',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acompanhe os valores previstos e recebidos em um único lugar.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum recebível cadastrado.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
