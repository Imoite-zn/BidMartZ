import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MyListTile({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey,
        ),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}