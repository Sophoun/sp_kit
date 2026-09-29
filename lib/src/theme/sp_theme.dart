import 'package:material_ui/material_ui.dart';

class SpTheme {
  /// Default radius of all
  static const double _radius = 8;

  /// It's shape style
  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(_radius)),
  );

  /// Light theme
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    cardTheme: const CardThemeData(shape: _shape),
    dialogTheme: const DialogThemeData(shape: _shape),
    popupMenuTheme: const PopupMenuThemeData(shape: _shape),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(_shape)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(_shape)),
    ),
  );

  /// Dark theme
  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    cardTheme: const CardThemeData(shape: _shape),
    dialogTheme: const DialogThemeData(shape: _shape),
    popupMenuTheme: const PopupMenuThemeData(shape: _shape),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(_shape),
        elevation: WidgetStatePropertyAll(0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(_shape),
        elevation: WidgetStatePropertyAll(0.2),
      ),
    ),
  );
}
