import 'package:ecomm_site/models/product_a.dart';
import 'package:ecomm_site/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductTile extends StatelessWidget {
  final BuyNowProduct product;

  const ProductTile({
    super.key,
    required this.product,
    });

    //add to cart button pressed
    void addItemToCart(BuildContext context) {
      //show dialog box to confirm addition
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          content: Text("Add to cart?"),
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
                context.read<Shop>().addItemToCart(product);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //product image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondary
              ),
              width: double.infinity,
              child: Image.asset(product.imagePath),
              padding: EdgeInsets.all(25),
              ),
          ),

          const SizedBox(height: 20,),

          //name
          Text(
            product.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            ),

          //desc
          Text(
            product.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary
            ),
            ),
            ],
          ),

          const SizedBox(height: 20,),

          //price + add to cart button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$' + product.price.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 20,
                ),
                ),

              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => addItemToCart(context),
                    color: Theme.of(context).colorScheme.inversePrimary,
                    icon: Icon(Icons.add),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}