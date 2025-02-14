import 'package:ecomm_site/components/buttton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.shopping_cart_sharp,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 20,),
        
            //title
            Text(
              'TrippMart',
              style: GoogleFonts.namdhinggo(
                textStyle: TextStyle(
                   fontSize: 25,
                   fontWeight: FontWeight.bold,
                ),
              ),
              ),

            const SizedBox(height: 10,),
        
            //sub-t
            Text(
              'Your trusted shopping destination',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              )
              ),
        
            //button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MyButton(
                onTap: () {
                  Navigator.pushNamed(context, '/shop');
                }, 
                child: Icon(Icons.arrow_forward)
                ),
            )
          ],
        ),
      ),
    );
  }
}