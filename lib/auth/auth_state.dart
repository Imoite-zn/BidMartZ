import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

mixin AuthStateMixin<T extends StatefulWidget> on State<T> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        onAuthenticated(event.session!);
      } else if (event.event == AuthChangeEvent.signedOut) {
        onUnauthenticated();
      } else if (event.event == AuthChangeEvent.passwordRecovery) {
        onPasswordRecovery(event.session!);
      }
    });
  }

  void onUnauthenticated() {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void onAuthenticated(Session session) {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void onPasswordRecovery(Session session) {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/reset-password', (route) => false);
    }
  }

  void onErrorAuthenticating(String message) {
    print('Error authenticating: $message');
  }
}