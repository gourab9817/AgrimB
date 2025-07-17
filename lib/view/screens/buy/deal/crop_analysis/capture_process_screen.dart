import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import 'package:agrimb/core/constants/app_text_style.dart';
import 'package:agrimb/core/constants/app_spacing.dart';
import './photo_capture_controller.dart';
import './photo_preview_screen.dart';

class CaptureProcessScreen extends StatefulWidget {
  final Function(String)? onPhotoSelected; // Made optional for new flow
  final String claimedId;

  const CaptureProcessScreen({
    Key? key,
    this.onPhotoSelected,
    required this.claimedId,
  }) : super(key: key);

  @override
  State<CaptureProcessScreen> createState() => _CaptureProcessScreenState();
}

class _CaptureProcessScreenState extends State<CaptureProcessScreen>
    with WidgetsBindingObserver {
  late PhotoCaptureController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = PhotoCaptureController();

    // Initialize controller after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialized) {
        _initialized = true;
        _controller.initializeController();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle state changes
    if (_controller.cameraController == null ||
        !_controller.cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // App going to background - dispose controller properly
      _controller.disposeCameraController();
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground - reinitialize controller
      if (mounted && _initialized) {
        _controller.initializeController();
      }
    }
  }

  void _navigateToPreview() async {
    try {
      // Capture the image
      await _controller.captureImage();

      if (_controller.capturedImage != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<PhotoCaptureController>.value(
              value: _controller,
              child: PhotoPreviewScreen(
                onPhotoSelected: widget.onPhotoSelected,
                claimedId: widget.claimedId,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<PhotoCaptureController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Camera Error',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => controller.initializeController(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!controller.isCameraInitialized ||
              controller.cameraController == null) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.orange,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Initializing camera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Take Photo',
                style: AppTextStyle.heading.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Camera preview - use Expanded to take available space
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CameraPreview(controller.cameraController!),
                        ),
                      ),
                    ),
                  ),

                  // Capture instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.orange.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo Guidelines',
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.brown,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.straighten, size: 14, color: Colors.red),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Keep the camera at a proper distance from the crop.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.red),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Ensure good lighting for a clear photo.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Capture controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Capture button
                        GestureDetector(
                          onTap: _navigateToPreview,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Space for symmetry
                        const SizedBox(width: 50),

                        // Camera switch button
                        InkWell(
                          onTap: controller.toggleCamera,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}