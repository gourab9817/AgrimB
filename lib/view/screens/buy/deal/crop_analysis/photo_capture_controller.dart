// lib/view/screens/Sell/photo_capture/photo_capture_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PhotoCaptureController with ChangeNotifier {
  // Camera controller
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  bool isCameraInitialized = false;
  bool isFrontCamera = false;
  bool isDisposed = false;
  
  // Image data
  File? capturedImage;
  String? imageUrl;
  
  // Loading states
  bool isLoading = false;
  String? errorMessage;
  
  PhotoCaptureController() {
    // Don't initialize in constructor to avoid lifecycle issues
  }
  
  Future<void> initializeController() async {
    if (isDisposed) return;
    
    setLoading(true);
    errorMessage = null;
    
    try {
      // Request camera permission
      final cameraPermissionStatus = await Permission.camera.request();
      if (cameraPermissionStatus.isDenied) {
        setError("Camera permission is required");
        setLoading(false);
        return;
      }
      
      // Initialize available cameras
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        setError("No camera found");
        setLoading(false);
        return;
      }
      
      // Initialize with back camera by default
      await _initializeCameraController(cameras[0]);
      setLoading(false);
    } catch (e) {
      if (!isDisposed) {
        setError("Failed to initialize camera: $e");
        setLoading(false);
      }
    }
  }
  
  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (isDisposed) return;
    
    // Safely dispose previous controller
    await disposeCameraController();
    
    // Create camera controller
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    // Initialize the controller
    try {
      await cameraController!.initialize();
      if (!isDisposed) {
        isCameraInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      if (!isDisposed) {
        setError("Failed to initialize camera: $e");
      }
    }
  }
  
  Future<void> disposeCameraController() async {
    if (cameraController != null) {
      try {
        final tempController = cameraController;
        cameraController = null;
        isCameraInitialized = false;
        if (tempController != null && tempController.value.isInitialized) {
          await tempController.dispose();
        }
      } catch (e) {
        print("Error disposing camera controller: $e");
      }
    }
  }
  
  void toggleCamera() async {
    if (isDisposed) return;
    if (cameras.length < 2) return;
    
    setLoading(true);
    
    try {
      isFrontCamera = !isFrontCamera;
      final newCameraIndex = isFrontCamera ? 1 : 0;
      
      if (newCameraIndex < cameras.length) {
        await _initializeCameraController(cameras[newCameraIndex]);
      }
    } catch (e) {
      if (!isDisposed) {
        setError("Failed to switch camera: $e");
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }
  
  Future<void> captureImage() async {
    if (isDisposed) return;
    if (cameraController == null || !cameraController!.value.isInitialized) {
      setError("Camera not initialized");
      return;
    }
    
    setLoading(true);
    
    try {
      // Capture the image
      final XFile photo = await cameraController!.takePicture();
      
      // Create a file from the captured image
      final imageFile = File(photo.path);
      
      // Verify the file exists
      if (!await imageFile.exists()) {
        setError("Failed to save captured image");
        setLoading(false);
        return;
      }
      
      capturedImage = imageFile;
      
      if (!isDisposed) {
        setLoading(false);
      }
    } catch (e) {
      if (!isDisposed) {
        setError("Failed to capture image: $e");
        setLoading(false);
      }
    }
  }
  
  Future<void> pickImageFromGallery() async {
    if (isDisposed) return;
    setLoading(true);
    
    try {
      // Try photos permission first (for newer API levels)
      final storagePermissionStatus = await Permission.photos.request();
      if (storagePermissionStatus.isDenied) {
        // Fall back to storage permission for older API levels
        final oldStoragePermissionStatus = await Permission.storage.request();
        if (oldStoragePermissionStatus.isDenied) {
          setError("Storage permission is required");
          setLoading(false);
          return;
        }
      }
      
      // Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress to save storage
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (photo != null) {
        // Create a file from the picked image
        final imageFile = File(photo.path);
        
        // Verify the file exists
        if (!await imageFile.exists()) {
          setError("Failed to load gallery image");
          setLoading(false);
          return;
        }
        
        capturedImage = imageFile;
      } else {
        // User canceled the picker
        if (!isDisposed) {
          setLoading(false);
        }
        return;
      }
      
      if (!isDisposed) {
        setLoading(false);
      }
    } catch (e) {
      if (!isDisposed) {
        setError("Failed to pick image: $e");
        setLoading(false);
      }
    }
  }
  
  Future<String> saveFinalImage() async {
    if (capturedImage == null) {
      throw Exception("No image to save");
    }
    
    try {
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      
      // Create a unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = path.join(tempPath, 'crop_$timestamp.jpg');
      
      // Copy the file to the new location
      final File newImage = await capturedImage!.copy(filePath);
      
      // Verify the new file exists
      if (!await newImage.exists()) {
        throw Exception("Failed to create a copy of the image file");
      }
      
      return newImage.path;
    } catch (e) {
      throw Exception("Failed to save image: $e");
    }
  }
  
  Future<String> saveImageLocally() async {
    if (capturedImage == null) {
      throw Exception("No image to save");
    }
    
    try {
      // Just return the existing path if the file already exists
      if (await capturedImage!.exists()) {
        return capturedImage!.path;
      } else {
        throw Exception("Image file doesn't exist");
      }
    } catch (e) {
      throw Exception("Failed to save image locally: $e");
    }
  }
  
  Future<String> uploadImageToFirebase() async {
    if (capturedImage == null) {
      throw Exception("No image to upload");
    }
    
    if (isDisposed) return "";
    
    setLoading(true);
    
    try {
      // Verify file exists before upload
      if (!await capturedImage!.exists()) {
        throw Exception("Image file doesn't exist");
      }
      
      // Create a unique filename
      final uuid = const Uuid();
      final String fileName = 'crops/${uuid.v4()}.jpg';
      
      // Debug prints
      print("Starting upload to Firebase Storage: $fileName");
      print("Image path: ${capturedImage!.path}");
      
      // Create a reference to the file location in Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      // Upload the file with metadata to work around certain issues
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'created': DateTime.now().toIso8601String()},
      );
      
      // Upload with progress tracking
      final UploadTask uploadTask = storageRef.putFile(capturedImage!, metadata);
      
      // Listen for upload progress to improve UX
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print("Upload progress: ${(progress * 100).toStringAsFixed(2)}%");
      });
      
      // Wait for the upload to complete with timeout
      final TaskSnapshot taskSnapshot = await uploadTask.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw Exception("Upload timed out after 2 minutes");
        },
      );
      
      // Get the download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("Upload completed successfully. URL: $downloadUrl");
      
      // Store the URL
      imageUrl = downloadUrl;
      
      if (!isDisposed) {
        setLoading(false);
      }
      return downloadUrl;
    } catch (e) {
      print("Firebase upload error: $e");
      if (!isDisposed) {
        setError("Failed to upload image: $e");
        setLoading(false);
      }
      throw Exception("Failed to upload image: $e");
    }
  }
  
  void resetImage() {
    if (isDisposed) return;
    capturedImage = null;
    imageUrl = null;
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    if (isDisposed) return;
    isLoading = loading;
    if (loading) {
      errorMessage = null;
    }
    notifyListeners();
  }
  
  void setError(String? message) {
    if (isDisposed) return;
    errorMessage = message;
    notifyListeners();
  }
  
  @override
  void dispose() {
    isDisposed = true;
    disposeCameraController();
    super.dispose();
  }
}