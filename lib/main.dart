import 'package:ecomm_site/models/shop.dart';
import 'package:ecomm_site/pages/buy_now_page.dart';
import 'package:ecomm_site/pages/cart_page.dart';
import 'package:ecomm_site/pages/exit_page.dart';
import 'package:ecomm_site/pages/home_page.dart';
import 'package:ecomm_site/pages/intro_page.dart';
import 'package:ecomm_site/pages/live_auction_page.dart';
import 'package:ecomm_site/pages/post_product_page.dart';
import 'package:ecomm_site/pages/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Shop(),
    child: const MyApp())
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      routes:{
        '/intro': (context) => const IntroPage(),
        '/home': (context) => const HomePage(),
        '/shop': (context) => const ShopPage(),
        '/cart': (context) => const CartPage(),
        '/exit': (context) => const ExitPage(),
        '/auctions': (context) => const LiveAuctionPage(),
        '/buy_now': (context) => const BuyNowPage(),
        '/post_product': (context) => const PostProductPage(),
      } 
    );
  }
}
