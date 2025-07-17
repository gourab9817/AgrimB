// lib/view/screens/Sell/photo_capture/check_your_crop.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import 'package:agrimb/core/constants/app_spacing.dart';
import 'package:agrimb/core/constants/app_text_style.dart';
import './photo_verification_screen.dart';
import 'package:agrimb/view/widgets/popup/custom_notification.dart';
import 'package:agrimb/data/services/crop_analysis_service.dart';
import '../../../../../data/models/crop_analysis_model.dart';
import './photo_capture_controller.dart';
import './photo_preview_screen.dart';

class CheckYourCropScreen extends StatefulWidget {
  final Function(String)? onPhotoSelected;
  final String claimedId;

  const CheckYourCropScreen({
    Key? key,
    this.onPhotoSelected,
    required this.claimedId,
  }) : super(key: key);

  @override
  State<CheckYourCropScreen> createState() => _CheckYourCropScreenState();
}

class _CheckYourCropScreenState extends State<CheckYourCropScreen> {
  bool _isChecking = false;
  CropAnalysisModel? _analysisResult;
  final CropAnalysisService _cropAnalysisService = CropAnalysisService();
  
  Future<void> _checkCrop() async {
    setState(() {
      _isChecking = true;
      _analysisResult = null;
    });

    try {
      final controller = Provider.of<PhotoCaptureController>(context, listen: false);
      
      if (controller.capturedImage == null || !controller.capturedImage!.existsSync()) {
        throw Exception('No image available for analysis');
      }

      // Use the crop analysis service
      final result = await _cropAnalysisService.analyzeCrop(controller.capturedImage!);
      
      if (result.isSuccess) {
        // Success - show analysis result and proceed
        setState(() {
          _analysisResult = result;
        });
        
        // Show success message
        CustomNotification.showSuccess(
          context: context,
          title: 'Analysis Complete',
          message: 'Your crop has been successfully analyzed.',
          duration: const Duration(seconds: 2),
        );
        
        // Wait for the notification to be visible, then navigate
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _navigateToVerification();
          }
        });
      } else {
        // API returned an error response
        final errorMessage = result.errorCode != null
            ? result.errorCode!.userFriendlyMessage
            : result.error ?? 'Unknown error occurred';
            
        _showErrorAndGoBack(
          errorMessage,
          errorCode: result.errorCode,
        );
      }
    } catch (e) {
      // Handle exceptions
      _showErrorAndGoBack(
        'Failed to analyze crop',
        errorCode: 'E999',
        details: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _showErrorAndGoBack(String message, {String? errorCode, String? details}) {
    CustomNotification.showError(
      context: context,
      title: 'Analysis Failed',
      message: '${errorCode != null ? '[$errorCode] ' : ''}$message${details != null ? '\n\n$details' : ''}',
      duration: const Duration(seconds: 4),
      onDismiss: () {
        // Navigate back to capture photo screen (pop twice)
        Navigator.pop(context); // Pop check your crop screen
        Navigator.pop(context); // Pop photo preview screen
      },
    );
  }

  void _navigateToVerification() {
    final controller = Provider.of<PhotoCaptureController>(context, listen: false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<PhotoCaptureController>.value(
          value: controller,
          child: PhotoVerificationScreen(
            onPhotoSelected: widget.onPhotoSelected,
            claimedId: widget.claimedId,
            apiResult: _analysisResult!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PhotoCaptureController>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check Your Crop',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image preview
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusL),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusL),
                    child: controller.capturedImage != null
                        ? Image.file(
                            controller.capturedImage!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Info text
                Text(
                  'Analyze Crop',
                  style: AppTextStyle.heading.copyWith(
                    color: AppColors.brown,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.m),
                
                Text(
                  'Check image quality before proceeding.',
                  style: AppTextStyle.body.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Analysis result (if available)
                if (_analysisResult != null && _analysisResult!.isSuccess == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusL),
                      border: Border.all(color: AppColors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.orange,
                          size: 40,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'Analysis Complete',
                          style: AppTextStyle.subheading.copyWith(
                            color: AppColors.brown,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        // Analysis details commented out as requested
                        // Text(
                        //   'Total Seeds: ${_analysisResult!.totalSeeds ?? 0}',
                        //   style: AppTextStyles.bodyLarge,
                        // ),
                        // Text(
                        //   'Healthy Seeds: ${_analysisResult!.healthySeeds ?? 0}',
                        //   style: AppTextStyles.bodyLarge.copyWith(
                        //     color: Colors.green,
                        //   ),
                        // ),
                        // Text(
                        //   'Defective Seeds: ${_analysisResult!.defectiveSeeds ?? 0}',
                        //   style: AppTextStyles.bodyLarge.copyWith(
                        //     color: Colors.red,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Check button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isChecking
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Analyzing...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text('Check Crop'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}