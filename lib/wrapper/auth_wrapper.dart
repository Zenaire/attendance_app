import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_services.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, this.authServices});

  final AuthServices? authServices;

  @override
  Widget build(BuildContext context) {
    final auth = authServices ?? AuthServices();
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen(authServices: auth);
        }
        return LoginScreen(authServices: auth);
      },
    );
  }
}
