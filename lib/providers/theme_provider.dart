import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Theme provider that manages app-wide theme state
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  /// Toggle between light and dark theme
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.dark;
        break;
    }
    
    developer.log(
      'Theme toggled to: ${_themeMode.name}',
      name: 'zeeky_social.theme',
      level: 800,
    );
    
    notifyListeners();
  }

  /// Set theme to light mode
  void setLightTheme() {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
      developer.log(
        'Theme set to light',
        name: 'zeeky_social.theme',
        level: 800,
      );
      notifyListeners();
    }
  }

  /// Set theme to dark mode
  void setDarkTheme() {
    if (_themeMode != ThemeMode.dark) {
      _themeMode = ThemeMode.dark;
      developer.log(
        'Theme set to dark',
        name: 'zeeky_social.theme',
        level: 800,
      );
      notifyListeners();
    }
  }

  /// Set theme to system mode (follows device settings)
  void setSystemTheme() {
    if (_themeMode != ThemeMode.system) {
      _themeMode = ThemeMode.system;
      developer.log(
        'Theme set to system',
        name: 'zeeky_social.theme',
        level: 800,
      );
      notifyListeners();
    }
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}