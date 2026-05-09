import 'package:flutter/material.dart';

class AdaptiveMenuScaffold extends StatelessWidget {
  const AdaptiveMenuScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.sideMenu,
    this.backgroundColor,
    this.desktopBreakpoint = 800,
    this.sideMenuWidth = 220,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
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
        endDrawer: endDrawer,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Body rendered first (behind), with left offset for the side menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: barHeight),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: sideMenuWidth),
                      child: body,
                    ),
                  ),
                ],
              ),
              // Side menu rendered after body so its shadow paints on top
              Positioned(
                top: barHeight,
                left: 0,
                bottom: 0,
                width: sideMenuWidth,
                child: sideMenu!,
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
      endDrawer: endDrawer,
      body: body,
    );
  }
}
