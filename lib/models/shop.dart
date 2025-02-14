import 'package:ecomm_site/models/product_a.dart';
import 'package:flutter/material.dart';

class Shop extends ChangeNotifier{
  //products for sale
  final List<ProductA> _shop = [
    //product1
    ProductA(
      name: "Bicycle", 
      price: 120.99, 
      description: "Black BMX", 
      imagePath: 'lib/assets/bmx.jpg'
      ),
      ProductA(
      name: "QuadBike", 
      price: 720.05, 
      description: "White and Blue Street Reverse gear Honda",
      imagePath: 'lib/assets/quad_2.jpg' 
      ),
      ProductA(
      name: "SpeedBike", 
      price: 2400.99, 
      description: "Red Ducati", 
      imagePath: 'lib/assets/speed_bike_1.jpg'
      ),
      ProductA(
      name: "Motorcycle", 
      price: 900.99, 
      description: "Night-Blue paint electric bike",
      imagePath: 'lib/assets/e_bike_1.jpg'
      ),
      ProductA(
      name: "Dirt Bike", 
      price: 1200.99, 
      description: "Dark Bluegrey all terrein Dirt Bike", 
      imagePath: 'lib/assets/dirt_bike.jpg'
      )
  ];

  //user cart
  List<ProductA> _cart =[];

  //get product list
  List<ProductA> get shop => _shop;

  //get user cart
  List<ProductA> get cart => _cart;

  //add item to cart 
  void addItemToCart(ProductA item) {
    _cart.add(item);
    notifyListeners();
  }

  //remove item from cart
  void removeItemFromCart(ProductA item) {
    _cart.remove(item);
    notifyListeners();
  }

}