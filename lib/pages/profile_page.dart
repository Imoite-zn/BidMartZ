import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
          'My Profile',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20),
          ),
        ),
    );
    // Navigator.pop(context);
  }
}