// ignore_for_file: unused_field, avoid_print

import 'dart:io';
import 'package:ecomm_site/models/product_a.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PostProductPage extends StatefulWidget {
  @override
  _PostProductPageState createState() => _PostProductPageState();
}

class _PostProductPageState extends State<PostProductPage> {
  List<BuyNowProduct> _products = [];
  final _textNameController = TextEditingController();
  final _textDescriptionController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textBuyNowPriceController = TextEditingController();
  File? _image;

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products');
    if (productsJson != null) {
      try{
        final products = jsonDecode(productsJson);
        setState(() {
         _products = products.map((product) => BuyNowProduct.fromJson(product)).toList();
      });
      } catch(e) {
        print('error loading products $e');
        setState(() {
          _products = [];
        });
      }
    }
    else {
      setState(() {
        _products = [];
        });
    }
  }

Future<void> _saveProduct(BuyNowProduct product) async {
  final prefs = await SharedPreferences.getInstance();
  final productsJson = prefs.getString('products');
  if (productsJson != null) {
    final products = jsonDecode(productsJson);
    products.add(product.toJson());
    await prefs.setString('products', jsonEncode(products));
  } else {
    await prefs.setString('products', jsonEncode([product.toJson()]));
  }
}

  void _addProduct() {
    if (_textNameController.text.isNotEmpty &&
        _textDescriptionController.text.isNotEmpty &&
        _textPriceController.text.isNotEmpty &&
        _image != null) {
      final product = BuyNowProduct(
        name: _textNameController.text,
        description: _textDescriptionController.text,
        price: double.parse(_textPriceController.text),
        imagePath: _image!.path,
      );
      _saveProduct(product).then((_) {
        _loadProducts();
      });
      _textNameController.clear();
      _textDescriptionController.clear();
      _textPriceController.clear();
      _image = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _textNameController,
            decoration: InputDecoration(
              label: Text('Name'),
            ),
          ),
          TextField(
            controller: _textDescriptionController,
            decoration: InputDecoration(
              label: Text('Description'),
            ),
          ),
          TextField(
            controller: _textPriceController,
            decoration: InputDecoration(
              label: Text('Price'),
            ),
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Select Image'),
          ),
          _image != null
              ? Image.file(_image!)
              : Text('No image selected'),
          ElevatedButton(
            onPressed: _addProduct,
            child: Text('Add Product'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_products[index].name),
                  subtitle: Text(_products[index].description),
                  trailing: Text('${_products[index].price}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

