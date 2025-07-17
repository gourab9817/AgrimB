// lib/view/screens/Sell/photo_capture/photo_verification_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import 'package:agrimb/core/constants/app_text_style.dart';
import './photo_capture_controller.dart';
import '../final_deal_screen.dart';
import '../../../../../data/models/crop_analysis_model.dart';

class PhotoVerificationScreen extends StatefulWidget {
  final Function(String)? onPhotoSelected; // Made optional
  final String claimedId;
  final CropAnalysisModel apiResult;

  const PhotoVerificationScreen({
    Key? key,
    this.onPhotoSelected,
    required this.claimedId,
    required this.apiResult,
  }) : super(key: key);

  @override
  State<PhotoVerificationScreen> createState() => _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PhotoCaptureController>(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    if (controller.capturedImage == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.brown),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Verify Image', style: AppTextStyle.bold18.copyWith(color: AppColors.brown)),
        ),
        body: Center(
          child: Text('No image available', style: AppTextStyle.body),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Verify Image', style: AppTextStyle.bold18.copyWith(color: AppColors.brown)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFF7F7F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 420 : constraints.maxWidth * 0.98,
                    minWidth: 280,
                  ),
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stepper/progress indicator
                      Padding(
                        padding: const EdgeInsets.only(top: 44, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                            _stepCircle(true, '1'),
                            _stepLine(),
                            _stepCircle(true, '2'),
                            _stepLine(),
                            _stepCircle(true, '3'),
                            _stepLine(),
                            _stepCircle(false, '4'),
                          ],
                        ),
                      ),
                      // Small captured image in a modern card
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                        color: Colors.white.withOpacity(0.92),
              child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            radius: isTablet ? 60 : 48,
                            backgroundColor: AppColors.white,
                            backgroundImage: FileImage(controller.capturedImage!),
                            onBackgroundImageError: (_, __) {},
                            child: controller.capturedImage == null
                                ? Icon(Icons.image, color: AppColors.brown, size: isTablet ? 60 : 48)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Eye icon button to toggle result visibility
                      Center(
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(_showResult ? Icons.visibility : Icons.visibility_off, color: AppColors.brown, size: 28),
                              tooltip: _showResult ? 'Hide Result' : 'Show Result',
                              onPressed: () {
                                setState(() {
                                  _showResult = !_showResult;
                                });
                              },
                              splashRadius: 24,
                            ),
                            Text(
                              _showResult ? 'Click to hide the analysis' : 'Click here to see the analysis',
                              style: AppTextStyle.medium14.copyWith(color: AppColors.brown.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      // Glassmorphic/frosted result card (animated)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _showResult
                            ? Container(
                                key: const ValueKey('resultCard'),
                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(
                                    colors: widget.apiResult.isSuccess
                                        ? [AppColors.lightOrange.withOpacity(0.8), Colors.white.withOpacity(0.8)]
                                        : [AppColors.error.withOpacity(0.08), Colors.white.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withOpacity(0.10),
                                      blurRadius: 22,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: widget.apiResult.isSuccess ? AppColors.orange.withOpacity(0.18) : AppColors.error.withOpacity(0.18),
                                    width: 1.2,
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
                                child: widget.apiResult.isSuccess
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                              const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                                              SizedBox(width: 12),
                                              Text('Crop Analysis Results', style: AppTextStyle.bold18.copyWith(color: AppColors.success)),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          _resultRow('Total Seeds', widget.apiResult.totalSeeds, AppColors.brown, Icons.grain),
                                          const SizedBox(height: 8),
                                          _resultRow('Healthy Seeds', widget.apiResult.healthySeeds, AppColors.success, Icons.eco),
                                          const SizedBox(height: 8),
                                          _resultRow('Defective Seeds', widget.apiResult.defectiveSeeds, AppColors.error, Icons.warning_amber_rounded),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          const Icon(Icons.error, color: AppColors.error, size: 28),
                                          SizedBox(width: 12),
                    Expanded(
                      child: Text(
                                              widget.apiResult.errorCode?.userFriendlyMessage ?? widget.apiResult.error ?? 'Unknown error',
                                              style: AppTextStyle.error,
                      ),
                    ),
                  ],
                ),
                              )
                            : const SizedBox.shrink(),
              ),
                      const SizedBox(height: 28),
            // Instructions
            Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                elevation: 0,
                          color: AppColors.orange.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppColors.orange.withOpacity(0.18)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                              'Please verify the photo and results before proceeding.',
                              style: AppTextStyle.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
                      const SizedBox(height: 38),
                      // Floating Next button
                      Align(
                        alignment: Alignment.center,
              child: SizedBox(
                          width: isTablet ? 220 : double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.arrow_forward, color: Colors.white),
                            label: Text('Next', style: AppTextStyle.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 8,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                                  builder: (context) => FinalDealScreen(claimedId: widget.claimedId),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _resultRow(String label, int? value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text('$label:', style: AppTextStyle.medium14.copyWith(color: color)),
        SizedBox(width: 8),
        Text(value != null ? value.toString() : '-', style: AppTextStyle.bold16.copyWith(color: color)),
      ],
    );
  }

  Widget _stepCircle(bool done, String step) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done ? AppColors.orange : AppColors.lightOrange,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.orange, width: 2),
      ),
      child: Center(
        child: Text(
          step,
          style: AppTextStyle.bold16.copyWith(color: done ? Colors.white : AppColors.orange),
        ),
      ),
    );
  }

  Widget _stepLine() {
    return Container(
      width: 32,
      height: 4,
      color: AppColors.orange.withOpacity(0.5),
    );
  }
}