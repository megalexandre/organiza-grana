import 'package:flutter/material.dart';
import 'package:organizagrana/features/recebiveis/presentation/pages/recebiveis_page.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_config.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_item.dart';
import 'package:organizagrana/shared/layout/layout_page.dart';
import 'package:organizagrana/shared/layout/page_section_layout.dart';
import 'package:organizagrana/shared/layout/surface_panel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onLogout, this.userEmail});

  final Future<void> Function() onLogout;
  final String? userEmail;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedItemId = 'dashboard';
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
      if (menuItems.isNotEmpty && !menuItems.any((item) => item.id == _selectedItemId)) {
        _selectedItemId = menuItems.first.id;
      }
    });
  }

  Widget _buildPageContent() {
    switch (_selectedItemId) {
      case 'recebiveis':
        return const RecebiveisPage();
      case 'dashboard':
      default:
        return const _DashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _menuItems.indexWhere((item) => item.id == _selectedItemId);

    return LayoutPage(
      title: 'Dashboard',
      menuItems: _menuItems,
      selectedIndex: selectedIndex,
      onMenuSelect: (i) => setState(() => _selectedItemId = _menuItems[i].id),
      onLogout: widget.onLogout,
      userEmail: widget.userEmail,
      body: _buildPageContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return const PageSectionLayout(
      title: 'Dashboard',
      subtitle: 'Visão geral dos indicadores e atalhos principais.',
      content: SurfacePanel(
        child: Center(
          child: Text('Conteúdo do dashboard'),
        ),
      ),
    );
  }
}
