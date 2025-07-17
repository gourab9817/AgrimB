// lib/view/screens/Sell/photo_capture/photo_preview_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import './photo_capture_controller.dart';
import './check_your_crop.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final Function(String)? onPhotoSelected; // Made optional for new flow
  final String claimedId;

  const PhotoPreviewScreen({
    Key? key,
    this.onPhotoSelected,
    required this.claimedId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    // Access controller - use listen: false for initialization to avoid rebuild loop
    final controller = Provider.of<PhotoCaptureController>(context, listen: false);
    
    // Simple check for image
    if (controller.capturedImage == null || !File(controller.capturedImage!.path).existsSync()) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Preview', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'No image captured',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Main screen
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Preview', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image container with fixed size
            Container(
              width: width,
              height: height * 0.6,
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.file(
                    controller.capturedImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading image: $error");
                      print("Image path: ${controller.capturedImage!.path}");
                      print("Image exists: ${File(controller.capturedImage!.path).existsSync()}");
                      return Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Simple button row with fixed heights
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake
                  MaterialButton(
                    onPressed: () {
                      controller.resetImage();
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                    textColor: Colors.black,
                    minWidth: 0,
                    height: 50,
                    padding: const EdgeInsets.all(15),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.refresh),
                  ),
                  
                  // Next - now navigates to CheckYourCropScreen
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider<PhotoCaptureController>.value(
                            value: controller,
                            child: CheckYourCropScreen(
                              onPhotoSelected: onPhotoSelected,
                              claimedId: claimedId,
                            ),
                          ),
                        ),
                      );
                    },
                    color: AppColors.orange,
                    textColor: Colors.white,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}