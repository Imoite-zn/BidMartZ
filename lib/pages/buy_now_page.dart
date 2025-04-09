import 'package:flutter/material.dart';

class BuyNowPage extends StatelessWidget {
  const BuyNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Now'),
        ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Text(
            'Buy Now',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              
              'Product Name',
              style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
        ]
      ),
    );
  }
}