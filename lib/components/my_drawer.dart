import 'package:ecomm_site/components/my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
               //drawer header: logo
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.shopping_cart_sharp,
                size: 70,
                color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
             ),

             const SizedBox(height: 10,),

          //shop tile
          MyListTile(
            text: "My profile", 
            icon: Icons.person_4_outlined, 
            onTap: () =>
              Navigator.pushNamed(context, '/profile'),
            ),
            
          //cart tile
           MyListTile(
            text: "Cart", 
            icon: Icons.shopping_cart_checkout_sharp, 
            onTap: () {
              //pop drawer first
              Navigator.pop(context);

              //go to cart page
              Navigator.pushNamed(context, '/cart');
            },
            ),
         
            ],
          ),
          
          //exit shop
           MyListTile(
            text: "Exit", 
            icon: Icons.exit_to_app_outlined, 
            onTap: () =>
              Navigator.pushNamedAndRemoveUntil(
                context, '/intro', (route) => false),
            ),

        ],
      ),
    );
  }
}