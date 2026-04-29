import 'package:flutter/material.dart';

class AdaptiveMenuScaffold extends StatelessWidget {
  const AdaptiveMenuScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.sideMenu,
    this.backgroundColor,
    this.desktopBreakpoint = 800,
    this.sideMenuWidth = 220,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? sideMenu;
  final Color? backgroundColor;
  final double desktopBreakpoint;
  final double sideMenuWidth;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= desktopBreakpoint;

    if (isDesktop && sideMenu != null) {
      final barHeight = appBar?.preferredSize.height ?? 0;
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: barHeight),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        sideMenu!,
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ],
              ),
              if (appBar != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(height: barHeight, child: appBar),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      body: body,
    );
  }
}
