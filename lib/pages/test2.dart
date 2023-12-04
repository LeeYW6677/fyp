import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageDownloadScreen extends StatefulWidget {
  @override
  _ImageDownloadScreenState createState() => _ImageDownloadScreenState();
}

class _ImageDownloadScreenState extends State<ImageDownloadScreen> {
  Uint8List imageData = Uint8List(8); // Store the downloaded image bytes

  // Function to download the image from Firebase Storage
  Future<void> downloadImage() async {
    String imagePath = 'E001/image_0.jpg'; // Replace with your actual image path
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);

    try {
      // Get download URL
      String url = await ref.getDownloadURL();

      // Download image bytes
      HttpClientRequest request = await HttpClient().getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);

      // Set the image bytes
      setState(() {
        imageData = bytes;
      });

    } catch (e) {
      // Handle errors (e.g., image not found)
      print('Error downloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Download Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageData != null)
              // Display the downloaded image as bytes
              Image.memory(imageData),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger image download on button click
                downloadImage();
              },
              child: Text('Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}