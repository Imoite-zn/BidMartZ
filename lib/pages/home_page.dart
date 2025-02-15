// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:ecomm_site/components/bottom_nav_bar.dart';
import 'package:ecomm_site/components/my_drawer.dart';
import 'package:ecomm_site/models/shop.dart';
import 'package:ecomm_site/pages/buy_now_page.dart';
import 'package:ecomm_site/pages/live_auction_page.dart';
import 'package:ecomm_site/pages/post_product_page.dart';
import 'package:ecomm_site/pages/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   //declarations are made before the override
   //selected index to control the bottom bar
    int _currentIndex = 0;

    //update index
    void navigateBottomBar(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    //pages to display
    final List<Widget> _pages = [
      const ShopPage(),
      const LiveAuctionPage(),
      const BuyNowPage(),
      const PostProductPage(),
    ];

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: const Text(
              'Senkee Shop',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold),
              )),
        ),
        actions: [
          //go to cart page
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(
              Icons.shopping_cart_outlined,
              size: 30,
              )
            ),
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _pages[_currentIndex],
    );
  }
}