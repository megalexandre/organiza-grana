import 'package:flutter/material.dart';

class AdaptiveMenuScaffold extends StatelessWidget {
  const AdaptiveMenuScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.sideMenu,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.desktopBreakpoint = 800,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? sideMenu;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= desktopBreakpoint;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: isDesktop ? null : drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: sideMenu == null
          ? body
          : Row(
              children: [
                if (isDesktop) sideMenu!,
                Expanded(child: body),
              ],
            ),
    );
  }
}
