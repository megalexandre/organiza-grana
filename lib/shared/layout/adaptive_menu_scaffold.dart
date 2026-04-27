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
    this.sideMenuWidth = 220,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? sideMenu;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double desktopBreakpoint;
  final double sideMenuWidth;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= desktopBreakpoint;

    Widget bodyLayout;
    if (sideMenu == null || !isDesktop) {
      bodyLayout = body;
    } else {
      bodyLayout = Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: sideMenuWidth),
              child: body,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: sideMenu!,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: isDesktop ? null : drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: bodyLayout,
    );
  }
}
