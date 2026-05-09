import 'package:flutter/material.dart';
import 'package:organizagrana/shared/layout/adaptive_menu_scaffold.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_item.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_side_menu.dart';
import 'package:organizagrana/shared/layout/top_bar/layout_top_bar.dart';
import 'package:organizagrana/shared/layout/top_bar/user_profile_panel.dart';

/// Combina [AdaptiveMenuScaffold] + [LayoutTopBar] + [LayoutSideMenu] /
/// [LayoutDrawer] em um único widget configurável.
class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
    required this.title,
    required this.menuItems,
    required this.selectedIndex,
    required this.onMenuSelect,
    required this.onLogout,
    required this.body,
    required this.userEmail,
    this.userAvatarUrl,
    this.logoutTooltip = 'Sair',
    this.backgroundColor = Colors.white,
    this.desktopBreakpoint = 800,
  });

  /// Título exibido na top bar.
  final String title;

  /// Itens do menu lateral.
  final List<LayoutMenuItem> menuItems;

  /// Índice do item atualmente selecionado.
  final int selectedIndex;

  /// Callback acionado quando o usuário seleciona um item do menu.
  final ValueChanged<int> onMenuSelect;

  /// Callback de logout (async).
  final Future<void> Function() onLogout;

  /// Conteúdo principal da página.
  final Widget body;

  final String userEmail;
  final String? userAvatarUrl;

  /// Tooltip do botão de logout na top bar.
  final String logoutTooltip;

  /// Cor de fundo do scaffold.
  final Color backgroundColor;

  /// Largura mínima para exibir o menu lateral fixo (desktop).
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuScaffold(
      backgroundColor: backgroundColor,
      desktopBreakpoint: desktopBreakpoint,
      appBar: LayoutTopBar(
        title: title,
        userEmail: userEmail,
        userAvatarUrl: userAvatarUrl,
      ),
      endDrawer: UserProfilePanel(
        onLogout: onLogout,
        userEmail: userEmail,
        userAvatarUrl: userAvatarUrl,
      ),
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
