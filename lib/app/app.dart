import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/providers/theme_provider.dart';
import 'package:zeeky_social/screens/auth_gate.dart';
import 'package:zeeky_social/app/theme.dart';

/// Main application widget with Material Design 3 theming
class ZeekySocialApp extends StatelessWidget {
  const ZeekySocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Zeeky Social',
          debugShowCheckedModeBanner: false,
          
          // Use the centralized theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // Start with the auth gate to handle authentication state
          home: const AuthGate(),
          
          // Configure routes (can be expanded later)
          // routes: AppRoutes.routes,
        );
      },
    );
  }
}