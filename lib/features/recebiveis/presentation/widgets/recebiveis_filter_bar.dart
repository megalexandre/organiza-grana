import 'package:flutter/material.dart';

class ReceivablesFilterBar extends StatelessWidget {
  const ReceivablesFilterBar({
    super.key,
    required this.withDiscarded,
    required this.onChanged,
  });

  final bool withDiscarded;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtros'),
      children: [
        CheckboxListTile(
          title: const Text('Exibir descartados'),
          value: withDiscarded,
          onChanged: (v) => onChanged(v ?? false),
        ),
      ],
    );
  }
}
