import 'package:flutter/material.dart';

/// Paleta de cores completa do design system.
abstract final class AppPalette {
  // Primary — Docker Desktop blue
  static const primary100 = Color(0xFFD6E4FB);
  static const primary200 = Color(0xFFAECAF7);
  static const primary300 = Color(0xFF7DAAEF);
  static const primary400 = Color(0xFF4D87E8);
  static const primary500 = Color(0xFF1D63ED);
  static const primary600 = Color(0xFF1551CC);
  static const primary700 = Color(0xFF0E3EA8);
  static const primary800 = Color(0xFF082D84);
  static const primary900 = Color(0xFF041B60);

  // Success
  static const success100 = Color(0xFFF1FCE3);
  static const success200 = Color(0xFFDAF7B8);
  static const success300 = Color(0xFFC2F08C);
  static const success400 = Color(0xFFA8EA5C);
  static const success500 = Color(0xFF8BE218);
  static const success600 = Color(0xFF6CBF10);
  static const success700 = Color(0xFF509C09);
  static const success800 = Color(0xFF367A04);
  static const success900 = Color(0xFF205701);

  // Info
  static const info100 = Color(0xFFE3F6FE);
  static const info200 = Color(0xFFB8E8FD);
  static const info300 = Color(0xFF8AD9FC);
  static const info400 = Color(0xFF5CC9FA);
  static const info500 = Color(0xFF45BEF7);
  static const info600 = Color(0xFF3095D4);
  static const info700 = Color(0xFF1F6FB0);
  static const info800 = Color(0xFF114D8C);
  static const info900 = Color(0xFF062F69);

  // Warning
  static const warning100 = Color(0xFFFFF6E5);
  static const warning200 = Color(0xFFFFE6B8);
  static const warning300 = Color(0xFFFFD48A);
  static const warning400 = Color(0xFFFFC15C);
  static const warning500 = Color(0xFFFFB83F);
  static const warning600 = Color(0xFFDB932A);
  static const warning700 = Color(0xFFB87219);
  static const warning800 = Color(0xFF94530B);
  static const warning900 = Color(0xFF703803);

  // Danger
  static const danger100 = Color(0xFFFFE8E5);
  static const danger200 = Color(0xFFFFC2B8);
  static const danger300 = Color(0xFFFF988A);
  static const danger400 = Color(0xFFFF6C5C);
  static const danger500 = Color(0xFFFF4032);
  static const danger600 = Color(0xFFDB2721);
  static const danger700 = Color(0xFFB81514);
  static const danger800 = Color(0xFF94080B);
  static const danger900 = Color(0xFF700206);
}

/// Tokens semânticos — tema dark (Docker Desktop).
abstract final class AppColors {
  // --- Primária ---
  static const primary = Color(0xFF1D63ED);          // Docker blue
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0E3EA8);  // Docker blue escuro
  static const onPrimaryContainer = Color(0xFFD6E4FB);

  // --- Secundária ---
  static const secondary = Color(0xFF1551CC);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF16192A); // Docker sidebar
  static const onSecondaryContainer = Color(0xFF9EA4B0);

  // --- Superfícies dark ---
  static const surface = Color(0xFF1C1F2E);            // Docker main bg
  static const onSurface = Color(0xFFE6EBF5);          // Docker text primário
  static const surfaceContainerHighest = Color(0xFF252A3A); // Docker row/card

  // --- Outline ---
  static const outline = Color(0xFF2D3347);
  static const outlineVariant = Color(0xFF252A3A);

  // --- Semânticas ---
  static const error = Color(0xFFF24444);     // Docker red
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF23C552);   // Docker green (running)
  static const onSuccess = Color(0xFF1C1F2E);
  static const info = AppPalette.info400;
  static const onInfo = Color(0xFF1C1F2E);
  static const warning = AppPalette.warning500;
  static const onWarning = Color(0xFF1C1F2E);
}

/// Tokens semânticos — tema light (Docker Desktop).
abstract final class AcalLightColors {
  // --- Primária ---
  static const primary = Color(0xFF1D63ED);            // Docker blue
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD6E4FB);   // azul claro
  static const onPrimaryContainer = Color(0xFF041B60);

  // --- Secundária ---
  static const secondary = Color(0xFF1551CC);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFEEF2FF); // sidebar Docker light
  static const onSecondaryContainer = Color(0xFF041B60);

  // --- Superfícies light ---
  static const surface = Color(0xFFF5F7FC);            // branco-azulado
  static const onSurface = Color(0xFF1C1F2E);          // Docker navy escuro
  static const surfaceContainerHighest = Color(0xFFE8EDFB);

  // --- Outline ---
  static const outline = Color(0xFFC4CCDF);
  static const outlineVariant = Color(0xFFD4DAE8);

  // --- Semânticas ---
  static const error = Color(0xFFF24444);     // Docker red
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF23C552);   // Docker green
  static const onSuccess = Color(0xFFFFFFFF);
  static const info = AppPalette.info700;
  static const onInfo = Color(0xFFFFFFFF);
  static const warning = AppPalette.warning600;
  static const onWarning = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      onError: AppColors.onError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1D2B),  // Docker navbar
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.secondaryContainer,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: IconThemeData(color: AppColors.onSurface),
        unselectedIconTheme: IconThemeData(color: Color(0xFF6B7380)),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF6B7380)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.secondaryContainer,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF252A3A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        space: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        filled: true,
        fillColor: Color(0xFF252A3A),
        hintStyle: TextStyle(color: Color(0xFF6B7380)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.onSurface),
        bodyLarge: TextStyle(color: AppColors.onSurface),
        titleMedium: TextStyle(color: AppColors.onSurface),
        titleLarge: TextStyle(color: AppColors.onSurface),
      ),
      listTileTheme: const ListTileThemeData(
        selectedTileColor: AppColors.primaryContainer,
        selectedColor: AppColors.onSurface,
        textColor: Color(0xFF9EA4B0),
        iconColor: Color(0xFF6B7380),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF252A3A),
        contentTextStyle: TextStyle(color: AppColors.onSurface),
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AcalLightColors.primary,
      onPrimary: AcalLightColors.onPrimary,
      primaryContainer: AcalLightColors.primaryContainer,
      onPrimaryContainer: AcalLightColors.onPrimaryContainer,
      secondary: AcalLightColors.secondary,
      onSecondary: AcalLightColors.onSecondary,
      secondaryContainer: AcalLightColors.secondaryContainer,
      onSecondaryContainer: AcalLightColors.onSecondaryContainer,
      surface: AcalLightColors.surface,
      onSurface: AcalLightColors.onSurface,
      outline: AcalLightColors.outline,
      outlineVariant: AcalLightColors.outlineVariant,
      error: AcalLightColors.error,
      onError: AcalLightColors.onError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AcalLightColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFEEF2FF),  // Docker navbar light
        foregroundColor: AcalLightColors.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AcalLightColors.secondaryContainer,
        indicatorColor: AcalLightColors.primaryContainer,
        selectedIconTheme: IconThemeData(color: AcalLightColors.primary),
        unselectedIconTheme: IconThemeData(color: Color(0xFF6B7380)),
        selectedLabelTextStyle: TextStyle(
          color: AcalLightColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF6B7380)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AcalLightColors.secondaryContainer,
      ),
      cardTheme: CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          side: const BorderSide(color: AcalLightColors.outlineVariant),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AcalLightColors.outlineVariant,
        space: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        filled: true,
        fillColor: Color(0xFFFFFFFF),
        hintStyle: TextStyle(color: Color(0xFF9EA4B0)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AcalLightColors.onSurface),
        bodyLarge: TextStyle(color: AcalLightColors.onSurface),
        titleMedium: TextStyle(color: AcalLightColors.onSurface),
        titleLarge: TextStyle(color: AcalLightColors.onSurface),
      ),
      listTileTheme: const ListTileThemeData(
        selectedTileColor: AcalLightColors.primaryContainer,
        selectedColor: AcalLightColors.primary,
        textColor: AcalLightColors.onSurface,
        iconColor: Color(0xFF6B7380),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1C1F2E),
        contentTextStyle: TextStyle(color: Color(0xFFE6EBF5)),
      ),
    );
  }
}
