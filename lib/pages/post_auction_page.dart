// Import necessary packages
import 'dart:async';
import 'dart:io';
import 'package:ecomm_site/components/buttton.dart';
import 'package:ecomm_site/models/auction_product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecomm_site/auth/auth_state.dart';
import 'dart:ui' as ui;
// import 'dart:convert';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

// Modify the PostProductPage widget to include the auction timer
class PostAuctionPage extends StatefulWidget {
  const PostAuctionPage({super.key});

  @override
  _PostAuctionPageState createState() => _PostAuctionPageState();
}

class _PostAuctionPageState extends State<PostAuctionPage> with AuthStateMixin {
  final _textNameController = TextEditingController();
  final _textDescriptionController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textAuctionDurationController = TextEditingController();
  File? _image;
  String _result = '';
  List<AuctionProduct> _auctionProducts = [];
  Timer? _timer;
  int _remainingTime = 0;
  final supabase = Supabase.instance.client;

  Future<File> _processImage(File imageFile) async {
    try {
      // Create a new ImagePicker instance
      final picker = ImagePicker();
      
      // Create XFile from the original file
      final XFile originalXFile = XFile(imageFile.path);
      
      // Get the image dimensions
      final decodedImage = await decodeImageFromList(await imageFile.readAsBytes());
      
      // Only resize if the image is larger than 700x700
      if (decodedImage.width > 700 || decodedImage.height > 700) {
        final XFile? resizedImage = await picker.pickImage(
          source: ImageSource.camera, // This is a workaround to use the image processor
          imageQuality: 85,
          maxWidth: 700,
          maxHeight: 700,
          preferredCameraDevice: CameraDevice.rear,
        );
        
        if (resizedImage != null) {
          return File(resizedImage.path);
        }
      }
      
      return imageFile;
    } catch (error) {
      print('Error processing image: $error');
      return imageFile;
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        final File imageFile = File(pickedFile.path);
        
        setState(() {
          _image = imageFile;
        });
        
        // Hide loading indicator
        Navigator.pop(context);
        
        // Check if square
        _checkIfSquare(_image!);
      }
    } catch (error) {
      // Hide loading indicator if showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $error')),
      );
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

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'auction_images/$fileName';

      // Upload the file to Supabase Storage
      await supabase
          .storage
          .from('auction_images')
          .upload(filePath, imageFile, fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false
          ));

      // Get the public URL of the uploaded image
      final String publicUrl = supabase
          .storage
          .from('auction_images')
          .getPublicUrl(filePath);

      // Show success alert
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Success'),
                ],
              ),
              content: Text('Image has been successfully uploaded!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }

      return publicUrl;
    } catch (error) {
      print('Error uploading image: $error');
      
      // Show error alert
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Upload Failed'),
                ],
              ),
              content: Text('Failed to upload image: $error'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      
      return null;
    }
  }

  Future<void> _addAuctionProduct() async {
    if (_textNameController.text.isNotEmpty &&
        _textDescriptionController.text.isNotEmpty &&
        _textPriceController.text.isNotEmpty &&
        _textAuctionDurationController.text.isNotEmpty &&
        _image != null) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        // Upload image to Supabase Storage
        final imageUrl = await _uploadImageToSupabase(_image!);
        
        if (imageUrl == null) {
          Navigator.pop(context); // Dismiss loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image')),
          );
          return;
        }

        print('Image uploaded successfully: $imageUrl'); // Debug print

        // Calculate end time
        final endTime = DateTime.now().add(
          Duration(seconds: int.parse(_textAuctionDurationController.text))
        );
        
        // Create the auction data
        final auctionData = {
          'name': _textNameController.text,
          'description': _textDescriptionController.text,
          'starting_price': int.parse(_textPriceController.text),
          'current_price': int.parse(_textPriceController.text),
          'image_url': imageUrl,
          'duration': int.parse(_textAuctionDurationController.text),
          'end_time': endTime.toIso8601String(),
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
        };

        print('Inserting auction data: $auctionData'); // Debug print

        // Insert auction into Supabase database
        final response = await supabase
            .from('auctions')
            .insert(auctionData)
            .select()
            .single();

        print('Database response: $response'); // Debug print

        // Create AuctionProduct with the ID from the response
        final auctionProduct = AuctionProduct(
          id: response['id'] as String,
          name: _textNameController.text,
          description: _textDescriptionController.text,
          price: int.parse(_textPriceController.text),
          image: _image!,
          auctionDuration: int.parse(_textAuctionDurationController.text),
        );

        // Dismiss loading indicator
        Navigator.pop(context);
        
        setState(() {
          _auctionProducts.add(auctionProduct);
          _remainingTime = auctionProduct.auctionDuration;
          _image = null;
          _textNameController.clear();
          _textDescriptionController.clear();
          _textPriceController.clear();
          _textAuctionDurationController.clear();
        });
        
        _startAuctionTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auction created successfully!')),
        );
      } catch (error) {
        print('Error creating auction: $error'); // Debug print
        // Dismiss loading indicator if still showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating auction: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
    }
  }

  void _startAuctionTimer() {
    _timer?.cancel();
    
    if (_auctionProducts.isNotEmpty) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _updateAuctionStatus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Auction has ended!')),
            );
          }
        });
      });
    }
  }

  Future<void> _updateAuctionStatus() async {
    try {
      if (_auctionProducts.isNotEmpty) {
        await supabase
            .from('auctions')
            .update({'status': 'ended'})
            .eq('id', _auctionProducts.last.id);
      }
    } catch (error) {
      print('Error updating auction status: $error');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textNameController.dispose();
    _textDescriptionController.dispose();
    _textPriceController.dispose();
    _textAuctionDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
      ),
    );
  }
}