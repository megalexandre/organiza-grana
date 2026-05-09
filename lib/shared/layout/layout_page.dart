import 'package:flutter/material.dart';
import 'package:organizagrana/shared/layout/adaptive_menu_scaffold.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_item.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_side_menu.dart';
import 'package:organizagrana/shared/layout/top_bar/layout_top_bar.dart';
import 'package:organizagrana/shared/layout/top_bar/user_profile_panel.dart';
import 'package:organizagrana/shared/layout/user_display_profile.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
    required this.title,
    required this.menuItems,
    required this.selectedIndex,
    required this.onMenuSelect,
    required this.onLogout,
    required this.body,
    this.profile,
    this.backgroundColor = Colors.white,
    this.desktopBreakpoint = 800,
  });

  final String title;
  final List<LayoutMenuItem> menuItems;
  final int selectedIndex;
  final ValueChanged<int> onMenuSelect;
  final Future<void> Function() onLogout;
  final Widget body;
  final UserDisplayProfile? profile;
  final Color backgroundColor;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuScaffold(
      backgroundColor: backgroundColor,
      desktopBreakpoint: desktopBreakpoint,
      appBar: LayoutTopBar(title: title, profile: profile),
      endDrawer: UserProfilePanel(onLogout: onLogout, profile: profile),
      drawer: LayoutDrawer(
        items: menuItems,
        selectedIndex: selectedIndex,
        onSelect: onMenuSelect,
        backgroundColor: backgroundColor,
      ),
      sideMenu: LayoutSideMenu(
        items: menuItems,
        selectedIndex: selectedIndex,
        onSelect: onMenuSelect,
        backgroundColor: backgroundColor,
      ),
      body: body,
    );
  }
}
