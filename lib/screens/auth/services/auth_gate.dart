// listen to auth state changes countinously and redirect to the appropriate screen

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/screens/auth/pages/login.dart';
import 'package:project/screens/home/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasShownLogin = false;

  @override
  void initState() {
    super.initState();
    // Clear any existing session on app start to force login
    _clearSessionOnStart();
  }

  Future<void> _clearSessionOnStart() async {
    try {
      // Sign out any existing session on app start
      await Supabase.instance.client.auth.signOut();
      setState(() {
        _hasShownLogin = true;
      });
    } catch (e) {
      // If signOut fails, still set flag
      setState(() {
        _hasShownLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we haven't processed the initial logout yet, show loading
    if (!_hasShownLogin) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoginScreen();
        }

        // Check for valid session
        final session = snapshot.hasData && snapshot.data != null
            ? snapshot.data!.session
            : null;

        if (session != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
