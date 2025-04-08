import 'package:flutter/material.dart';
import 'auth_state.dart';

class AuthRequiredState<T extends StatefulWidget> extends AuthState<T> {
  @override
  void initState() {
    super.initState();
    _redirectIfNotSignedIn();
  }

  Future<void> _redirectIfNotSignedIn() async {
    if (!mounted) return;
    
    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}