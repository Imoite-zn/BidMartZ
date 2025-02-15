// ignore_for_file: unused_local_variable
import 'package:ecomm_site/components/product_tile.dart';
import 'package:ecomm_site/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {

    //access products in shop
    final products = context.watch<Shop>().shop;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: [
          const SizedBox(height: 25,),
          //Shop subtitle
          Center(
            child: Text(
              "Own your dream bike today!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary
              ),
              )
              ),

          //product list
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

        ],
      ),
    );
  }
}