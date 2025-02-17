import 'package:ecomm_site/models/product_a.dart';
import 'package:flutter/material.dart';

class Shop extends ChangeNotifier{
  //products for sale
  final List<BuyNowProduct> _shop = [
    //product1
    BuyNowProduct(
      name: "Bicycle", 
      price: 120.99, 
      description: "Black BMX", 
      imagePath: 'lib/assets/bmx.jpg'
      ),
      BuyNowProduct(
      name: "QuadBike", 
      price: 720.05, 
      description: "White and Blue Street Reverse gear Honda",
      imagePath: 'lib/assets/quad_2.jpg' 
      ),
      BuyNowProduct(
      name: "SpeedBike", 
      price: 2400.99, 
      description: "Red Ducati", 
      imagePath: 'lib/assets/speed_bike_1.jpg'
      ),
      BuyNowProduct(
      name: "Motorcycle", 
      price: 900.99, 
      description: "Night-Blue paint electric bike",
      imagePath: 'lib/assets/e_bike_1.jpg'
      ),
      BuyNowProduct(
      name: "Dirt Bike", 
      price: 1200.99, 
      description: "Dark Bluegrey all terrein Dirt Bike", 
      imagePath: 'lib/assets/dirt_bike.jpg'
      )
  ];

  //user cart
  List<BuyNowProduct> _cart =[];

  //get product list
  List<BuyNowProduct> get shop => _shop;

  //get user cart
  List<BuyNowProduct> get cart => _cart;

  //add item to cart 
  void addItemToCart(BuyNowProduct item) {
    _cart.add(item);
    notifyListeners();
  }

  //remove item from cart
  void removeItemFromCart(BuyNowProduct item) {
    _cart.remove(item);
    notifyListeners();
  }

}