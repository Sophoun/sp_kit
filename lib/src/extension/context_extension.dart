import 'package:material_ui/material_ui.dart';

extension SafePopExtension on BuildContext? {
  /// Handle safe pop for screen
  void safePop() {
    if (this == null) return;
    if (Navigator.of(this!).canPop()) {
      Navigator.of(this!).pop();
    }
  }
}

extension ThemeExtension on BuildContext? {
  /// Get current theme
  ThemeData? get theme => this == null ? null : Theme.of(this!);

  /// Get current text theme
  TextTheme? get textTheme => theme?.textTheme;

  /// Get current color scheme
  ColorScheme? get colorScheme => theme?.colorScheme;

  /// Get button theme
  ButtonThemeData? get buttonTheme => theme?.buttonTheme;
}

/// Keyboard extension
extension KeyboardExtension on BuildContext? {
  /// Hide keyboard
  void hideKeyboard() {
    if (this == null) return;
    FocusScope.of(this!).unfocus();
  }

  /// Show keyboard
  void showKeyboard(FocusNode? focusNode) {
    if (this == null) return;
    FocusScope.of(this!).requestFocus(focusNode ?? FocusNode());
  }
}
