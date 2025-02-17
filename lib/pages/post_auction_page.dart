// Import necessary packages
import 'dart:async';
import 'dart:io';
import 'package:ecomm_site/components/buttton.dart';
import 'package:ecomm_site/models/auction_product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Modify the PostProductPage widget to include the auction timer
class PostAuctionPage extends StatefulWidget {
  @override
  _PostAuctionPageState createState() => _PostAuctionPageState();
}

class _PostAuctionPageState extends State<PostAuctionPage> {
  File? _image;
  String _result = '';
  List<AuctionProduct> _auctionProducts = [];
  final _textNameController = TextEditingController();
  final _textDescriptionController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textAuctionDurationController = TextEditingController();
  Timer? _auctionTimer;
  int _remainingTime = 0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _checkIfSquare(_image!);
    }
  }

  Future<void> _checkIfSquare(File image) async {
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    if (decodedImage.width != decodedImage.height) {
      setState(() {
        AlertDialog(
          title: Text('Image is not square'),
        );
        _result = 'The image is not square';
      });
    }
  }

  void _addAuctionProduct() {
    if (_textNameController.text.isNotEmpty &&
        _textDescriptionController.text.isNotEmpty &&
        _textPriceController.text.isNotEmpty &&
        _textAuctionDurationController.text.isNotEmpty) {
      setState(() {
        _auctionProducts.add(AuctionProduct(
          name: _textNameController.text,
          description: _textDescriptionController.text,
          price: int.parse(_textPriceController.text),
          image: _image!,
          auctionDuration: int.parse(_textAuctionDurationController.text),
        ));
        _textNameController.clear();
        _textDescriptionController.clear();
        _textPriceController.clear();
        _textAuctionDurationController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void _startAuctionTimer() {
    if (_auctionProducts.isNotEmpty) {
      setState(() {
        _remainingTime = _auctionProducts.last.auctionDuration;
      });
      _auctionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime--;
          if (_remainingTime <= 0) {
            _auctionTimer?.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Add New Auction Product',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 250,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            margin: EdgeInsets.all(10),
            child: IconButton(
              onPressed: _pickImage,
              icon: Icon(
                Icons.add_a_photo_rounded,
                size: 40,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 400,
              height: 200,
              padding: EdgeInsets.all(5.0),
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _textNameController,
                        decoration: InputDecoration(
                          label: Text('Name'),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _textNameController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _textDescriptionController,
                        decoration: InputDecoration(
                          label: Text('Description'),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _textDescriptionController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _textPriceController,
                        decoration: InputDecoration(
                          label: Text('Price'),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _textPriceController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _textAuctionDurationController,
                        decoration: InputDecoration(
                          label: Text('Auction Duration (seconds)'),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _textAuctionDurationController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          MyButton(
            onTap: _addAuctionProduct,
            child: Text("Add Auction Product"),
          ),
          MyButton(
            onTap: _startAuctionTimer,
            child: Text("Start Auction Timer"),
          ),
          Text(
            'Remaining Time: $_remainingTime seconds',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}