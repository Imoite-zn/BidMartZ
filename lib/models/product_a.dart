class BuyNowProduct {
  final String name;
  final double price;
  final String description;
  final String imagePath;

  BuyNowProduct({
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  });
  
  factory BuyNowProduct.fromJson(Map<String, dynamic> json) {
    return BuyNowProduct(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
    };
  }
}