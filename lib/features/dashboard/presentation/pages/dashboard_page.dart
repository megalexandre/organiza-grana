import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/dashboard/presentation/widgets/dashboard_summary_cards.dart';
import 'package:organizagrana/features/dashboard/presentation/widgets/receivables_by_status_panel.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_config.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_item.dart';
import 'package:organizagrana/shared/layout/layout_page.dart';
import 'package:organizagrana/shared/layout/page_section_layout.dart';
import 'package:organizagrana/shared/layout/user_display_profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onLogout,
    required this.currentItemId,
    required this.body,
    this.profile,
  });

  final Future<void> Function() onLogout;
  final String currentItemId;
  final Widget body;
  final UserDisplayProfile? profile;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<LayoutMenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final items = await LayoutMenuConfig.load();
    if (!mounted) return;
    final menuItems = items.where((item) => item.isItem).toList();
    setState(() {
      _menuItems = menuItems;
    });
  }

  void _handleMenuSelect(int index) {
    final itemId = _menuItems[index].id;
    context.go(AppRouter.pathForItem(itemId));
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _menuItems.indexWhere(
      (item) => item.id == widget.currentItemId,
    );
    final title = selectedIndex >= 0
        ? _menuItems[selectedIndex].label
        : 'Dashboard';

    return LayoutPage(
      title: title,
      menuItems: _menuItems,
      selectedIndex: selectedIndex,
      onMenuSelect: _handleMenuSelect,
      onLogout: widget.onLogout,
      profile: widget.profile,
      body: widget.body,
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key, required this.service});

  final DashboardService service;

  @override
  Widget build(BuildContext context) {
    return PageSectionLayout(
      title: 'Dashboard',
      subtitle: 'Visão geral dos indicadores e atalhos principais.',
      content: ReceivablesByStatusPanel(service: service),
      children: [DashboardSummaryCards(service: service)],
    );
  }
}
