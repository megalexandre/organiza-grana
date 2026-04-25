import 'package:flutter/material.dart';

class PageSectionLayout extends StatelessWidget {
  const PageSectionLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.headerGap = 12,
    this.childrenGap = 24,
    this.contentGap = 20,
    this.children = const [],
    required this.content,
  });

  final String title;
  final String subtitle;
  final double headerGap;
  final double childrenGap;
  final double contentGap;
  final List<Widget> children;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: headerGap),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          if (children.isNotEmpty) ...[
            SizedBox(height: childrenGap),
            ...children,
          ],
          SizedBox(height: contentGap),
          Expanded(child: content),
        ],
      ),
    );
  }
}
