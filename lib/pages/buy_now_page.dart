import 'package:ecomm_site/components/product_tile.dart';
import 'package:ecomm_site/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyNowPage extends StatelessWidget {
  const BuyNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<Shop>().shop;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Now'),
        ),
      body: ListView(
        children: [
          SizedBox(height: 20),

          //adding 
         SizedBox(
            height: 550,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                //get each indiviual product
                final product = products[index];
            
                //return as a product UI
                return ProductTile(product: product);
              },
              ),
          ),
        ]
      ),
    );
  }
}