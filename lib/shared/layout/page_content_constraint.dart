import 'package:flutter/material.dart';

const double kPageContentMaxWidth = 720.0;

class PageContentConstraint extends StatelessWidget {
  const PageContentConstraint({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kPageContentMaxWidth),
        child: child,
      ),
    );
  }
}
