import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:organizagrana/shared/layout/side_menu/layout_menu_item.dart';

class LayoutMenuConfig {
  const LayoutMenuConfig._();

  static const String _defaultAssetPath = 'assets/config/nav_menu.json';

  static Future<List<LayoutMenuItem>> load({String assetPath = _defaultAssetPath}) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = json.decode(raw) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(LayoutMenuItem.fromJson)
        .toList();
  }
}
