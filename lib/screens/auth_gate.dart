import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/login_screen.dart';
import '../main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // User is logged in
        return const MainScreen();
      },
    );
  }
}
