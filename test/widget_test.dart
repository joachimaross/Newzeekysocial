// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/app/app.dart';
import 'package:zeeky_social/providers/theme_provider.dart';

void main() {
  group('Zeeky Social App Tests', () {
    testWidgets('App initializes correctly', (WidgetTester tester) async {
      // Build the app with required providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(),
            ),
          ],
          child: const ZeekySocialApp(),
        ),
      );

      // Verify that the app builds without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Theme provider works correctly', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      // Test initial state
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Test toggle
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Test specific setters
      themeProvider.setDarkTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      themeProvider.setSystemTheme();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    testWidgets('App shows correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(),
            ),
          ],
          child: const ZeekySocialApp(),
        ),
      );

      // Find the MaterialApp and verify title
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Zeeky Social');
    });
  });
}
