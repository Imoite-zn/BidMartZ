import 'package:ecomm_site/models/shop.dart';
import 'package:ecomm_site/pages/buy_now_page.dart';
import 'package:ecomm_site/pages/cart_page.dart';
import 'package:ecomm_site/pages/exit_page.dart';
import 'package:ecomm_site/pages/home_page.dart';
import 'package:ecomm_site/pages/intro_page.dart';
import 'package:ecomm_site/pages/live_auction_page.dart';
import 'package:ecomm_site/pages/post_auction_page.dart';
import 'package:ecomm_site/pages/post_product_page.dart';
import 'package:ecomm_site/pages/profile_page.dart';
import 'package:ecomm_site/pages/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecomm_site/auth/auth_provider.dart';
import 'package:ecomm_site/pages/auth/login_page.dart';
import 'package:ecomm_site/pages/auth/signup_page.dart';
import 'package:ecomm_site/providers/auction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase with values from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => Shop()),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
      ],
      child: const MyApp(),
    ),
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
      initialRoute: '/login',
      routes:{
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/intro': (context) => const IntroPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/shop': (context) => const ShopPage(),
        '/cart': (context) => const CartPage(),
        '/exit': (context) => const ExitPage(),
        '/auctions': (context) => const LiveAuctionPage(),
        '/buy_now': (context) => const BuyNowPage(),
        '/post_auction': (context) => PostAuctionPage(),
        '/post_product': (context) => PostProductPage(),
      } 
    );
  }
}
