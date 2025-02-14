import 'package:ecomm_site/components/buttton.dart';
import 'package:ecomm_site/models/product_a.dart';
import 'package:ecomm_site/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  
  const CartPage({super.key});

  //remove item from cart
  void removeItemFromCart(BuildContext context, ProductA product) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          content: Text("Remove from cart?"),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            //cancel button
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                  ),
              ),
              ),

            //proceed button
            MaterialButton(
              onPressed: () {
                //add product to cart
                context.read<Shop>().removeItemFromCart(product);

                //pop box
                Navigator.pop(context);
                },
              child: Text(
                "Proceed",
                style: TextStyle(color: Colors.green),
                ),
              ),

          ],
        )
      );
  }

  //user pressed pay btn
  void payButtonPressed (BuildContext context) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: Text('user wants to pay, connect to the paywall'),
      )
      );
  }

  @override
  Widget build(BuildContext context) {
    //get access to cart
    final cart = context.watch<Shop>().cart;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Cart'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          //cart list
          Expanded(
            child: cart.isEmpty? Center(
              child: Text(
                'No bikes yet?',
                style: TextStyle(
                  fontSize: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
                ),
            ) : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                //get individual item in cart
                final item = cart[index];

                //return as acart tile UI
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.price.toStringAsFixed(2)),
                  trailing: IconButton(
                    onPressed: () => removeItemFromCart(context, item), 
                    icon: Icon(Icons.remove_circle)),
                );
              }
              ),
          ),

          //pay button
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: MyButton(
              onTap: () => payButtonPressed(context), 
              child: Text('Pay Now'),
              ),
          ),
        ],
      ),
    );
  }
  
}