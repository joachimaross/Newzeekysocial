import 'package:flutter_test/flutter_test.dart';
import 'package:zeeky_social/providers/theme_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('Initial theme mode is system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('Toggle theme works correctly', () {
      // Start with system, toggle should go to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Toggle again should go to light
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);

      // Toggle again should go to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('Set light theme works', () {
      themeProvider.setLightTheme();
      expect(themeProvider.themeMode, ThemeMode.light);

      // Setting the same theme should not change anything
      themeProvider.setLightTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('Set dark theme works', () {
      themeProvider.setDarkTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Setting the same theme should not change anything
      themeProvider.setDarkTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('Set system theme works', () {
      // Change to light first
      themeProvider.setLightTheme();
      expect(themeProvider.themeMode, ThemeMode.light);

      // Set to system
      themeProvider.setSystemTheme();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('Provider notifies listeners on change', () {
      var notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      // Toggle should notify
      themeProvider.toggleTheme();
      expect(notificationCount, 1);

      // Setting different theme should notify
      themeProvider.setSystemTheme();
      expect(notificationCount, 2);

      // Setting same theme should not notify
      themeProvider.setSystemTheme();
      expect(notificationCount, 2);
    });
  });
}