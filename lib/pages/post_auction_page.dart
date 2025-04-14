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
import 'package:ecomm_site/providers/auction_provider.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img; // Import image package
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p; // For path manipulation

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
  Timer? _timer;
  int _remainingTime = 0;
  final supabase = Supabase.instance.client;
  final int _minImageSize = 500;
  final int _targetImageSize = 500;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return; // User cancelled picker

      final File originalImageFile = File(pickedFile.path);
      final imageBytes = await originalImageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Could not decode image.');
      }

      // 1. Check Minimum Dimensions
      if (decodedImage.width < _minImageSize || decodedImage.height < _minImageSize) {
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Image Too Small'),
            content: Text('Please select an image that is at least $_minImageSize x $_minImageSize pixels.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
            ],
          ),
        );
        return; // Stop processing
      }

      // 2. Resize if necessary (show loading indicator)
      // ignore: use_build_context_synchronously
      showDialog(
        context: context, // Use context available before async gap
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               CircularProgressIndicator(),
               SizedBox(height: 10), 
               Text("Processing image...")
            ]
          ));
        },
      );

      File finalImageFile; 
      try {
          finalImageFile = await _resizeImage(originalImageFile);
      } catch (e) {
           print("Error resizing image: $e");
           // ignore: use_build_context_synchronously
           Navigator.pop(context); // Dismiss loading dialog
           // ignore: use_build_context_synchronously
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing image: ${e.toString()}')),
           );
           return;
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Dismiss loading dialog

      // 3. Update State with the final (possibly resized) image
      setState(() {
        _image = finalImageFile;
        _result = ''; // Clear previous errors
      });

    } catch (error) {
      // Hide loading indicator if it's somehow still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking/processing image: ${error.toString()}')),
      );
    }
  }

  // New function to resize image to a 500x500 square
  Future<File> _resizeImage(File originalFile) async {
    final imageBytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Could not decode image for resizing.');
    }

    // Resize and crop to a square
    img.Image resizedImage = img.copyResizeCropSquare(originalImage, size: _targetImageSize);

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final String fileExtension = p.extension(originalFile.path).toLowerCase();
    final String tempPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}_resized$fileExtension');

    // Encode based on original extension (default to jpg)
    List<int> encodedBytes;
    if (fileExtension == '.png') {
       encodedBytes = img.encodePng(resizedImage);
    } else {
       // Default to JPG with quality
       encodedBytes = img.encodeJpg(resizedImage, quality: 85);
    }

    // Write the bytes to the temporary file
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(encodedBytes);

    print('Resized image saved to temporary path: ${tempFile.path}');
    return tempFile;
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'auction_images/$fileName';

      await supabase
          .storage
          .from('auction_images')
          .upload(filePath, imageFile, fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false
          ));

      final String publicUrl = supabase
          .storage
          .from('auction_images')
          .getPublicUrl(filePath);
          
      return publicUrl;

    } catch (error) {
      print('Error uploading image: $error');
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
    final name = _textNameController.text;
    final description = _textDescriptionController.text;
    final priceString = _textPriceController.text;
    final durationString = _textAuctionDurationController.text;

    // Improved Input Validation
    final startingPrice = int.tryParse(priceString);
    final durationSeconds = int.tryParse(durationString);

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        startingPrice != null && // Check parsed value
        durationSeconds != null && // Check parsed value
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
            SnackBar(content: Text('Image upload failed. Please try again.')),
          );
          return;
        }

        print('Image uploaded successfully: $imageUrl'); // Debug print

        // Calculate end time
        final endTime = DateTime.now().add(
          Duration(seconds: durationSeconds) // Use parsed value
        );

        final auctionData = {
          'name': name,
          'description': description,
          'starting_price': startingPrice, // Use parsed value
          'current_price': startingPrice, // Use parsed value (or fetch if logic differs)
          'image_url': imageUrl,
          'duration': durationSeconds, // Use parsed value
          'end_time': endTime.toIso8601String(),
          'status': 'active',
          'seller_id': supabase.auth.currentUser!.id, // Ensure seller_id is included if not default
        };

        print('Inserting auction data: $auctionData'); // Debug print

        // Insert auction into Supabase database
        // Assumes RLS policy allows insert and sets seller_id=auth.uid()
        final response = await supabase
            .from('auctions')
            .insert(auctionData)
            .select() // Select the inserted row to get the ID
            .single(); // Expect exactly one row

        print('Database response: $response'); // Debug print

        // Ensure response is not null and contains an ID
        if (response == null || response['id'] == null) {
           throw Exception('Failed to create auction: No ID returned from database.');
        }

        // Create AuctionProduct from the response data using the factory
        final newAuction = AuctionProduct.fromJson(response as Map<String, dynamic>); 

        // Add the new auction to the provider
        // ignore: use_build_context_synchronously
        Provider.of<AuctionProvider>(context, listen: false).addAuctionLocally(newAuction);

        // Dismiss loading indicator
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        setState(() {
          // Clear form fields, no need to manage local list or timer here
          _image = null; 
          _textNameController.clear();
          _textDescriptionController.clear();
          _textPriceController.clear();
          _textAuctionDurationController.clear();
          _remainingTime = 0; // Reset local timer display if any
          _timer?.cancel();  // Cancel local timer
        });

        // No need to call _startAuctionTimer here, LiveAuctionPage will handle display

        // ignore: use_build_context_synchronously
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
          // Provide a more user-friendly error
          SnackBar(content: Text('Error creating auction: ${error.toString()}')),
        );
      }
    } else {
      // More specific feedback
      String errorMessage = 'Please fill in all fields correctly.';
      if (_image == null) {
        errorMessage = 'Please select an image.';
      } else if (startingPrice == null) {
         errorMessage = 'Please enter a valid number for the price.';
      } else if (durationSeconds == null) {
         errorMessage = 'Please enter a valid number for the duration.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    // Cancel timer if it's still running
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
              color: _image == null ? Theme.of(context).colorScheme.primary : Colors.grey[300],
              margin: EdgeInsets.all(10),
              child: _image != null
                  ? Image.file( // Display the selected (potentially resized) image
                      _image!, 
                      fit: BoxFit.contain, // Use contain to see the whole square
                    )
                  : IconButton( // Show button only if no image
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                        color: _image == null ? null : Colors.black54,
                      ),
                    ),
            ),
            if (_image != null)
              TextButton.icon(
                icon: Icon(Icons.edit), 
                label: Text("Change Image"),
                onPressed: _pickImage,
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