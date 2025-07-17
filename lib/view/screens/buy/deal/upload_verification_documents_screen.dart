import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../view_model/buy/deal/upload_verification_documents_view_model.dart';

class UploadVerificationDocumentsScreen extends StatelessWidget {
  final String claimedId;
  const UploadVerificationDocumentsScreen({Key? key, required this.claimedId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadVerificationDocumentsViewModel(
        userRepository: Provider.of<UserRepository>(context, listen: false),
        claimedId: claimedId,
      ),
      child: const _UploadVerificationDocumentsBody(),
    );
  }
}

class _UploadVerificationDocumentsBody extends StatelessWidget {
  const _UploadVerificationDocumentsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UploadVerificationDocumentsViewModel>(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 500;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightOrange, AppColors.background],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 440 : width * 0.98,
                  minWidth: 280,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: AppColors.orange, size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Upload Verification Documents',
                              style: AppTextStyle.bold20.copyWith(color: AppColors.brown),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _UploadSection(
                        label: 'Upload signed contract 📝',
                        color: AppColors.originalLightOrange,
                        iconColor: AppColors.orange,
                        isSquare: true,
                        isUploading: viewModel.isContractUploading,
                        imageFile: viewModel.contractImage,
                        onTap: () => viewModel.pickAndUploadContract(context),
                      ),
                      const SizedBox(height: 22),
                      Divider(color: AppColors.divider, thickness: 1, height: 1),
                      const SizedBox(height: 22),
                      _UploadSection(
                        label: 'Take a Selfie with the Farmer🥄',
                        color: AppColors.lightBrown,
                        iconColor: AppColors.success,
                        isSquare: true,
                        isUploading: viewModel.isSelfieUploading,
                        imageFile: viewModel.selfieImage,
                        onTap: () => viewModel.pickAndUploadSelfie(context),
                      ),
                      const SizedBox(height: 22),
                      Divider(color: AppColors.divider, thickness: 1, height: 1),
                      const SizedBox(height: 22),
                      _UploadSection(
                        label: 'Upload Final Produce Photo🌾',
                        color: AppColors.lightOrange,
                        iconColor: AppColors.brown,
                        isSquare: true,
                        isUploading: viewModel.isProduceUploading,
                        imageFile: viewModel.produceImage,
                        onTap: () => viewModel.pickAndUploadProduce(context),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: ElevatedButton(
                            onPressed: viewModel.isContractUploading || viewModel.isSelfieUploading || viewModel.isProduceUploading
                                ? null
                                : () async {
                                    await viewModel.uploadAllSelectedImages(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shadowColor: AppColors.orange.withOpacity(0.18),
                            ),
                            child: viewModel.isContractUploading || viewModel.isSelfieUploading || viewModel.isProduceUploading
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Submit',
                                      style: AppTextStyle.bold18.copyWith(color: Colors.white, letterSpacing: 0.5),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final String label;
  final Color color;
  final Color iconColor;
  final bool isSquare;
  final bool isUploading;
  final File? imageFile;
  final VoidCallback onTap;
  const _UploadSection({
    required this.label,
    required this.color,
    required this.iconColor,
    this.isSquare = false,
    this.isUploading = false,
    this.imageFile,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 500;
    final double cardSize = isSquare ? (isWide ? 180 : width * 0.7) : double.infinity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.bold16.copyWith(color: iconColor),
        ),
        const SizedBox(height: 8),
        Center(
          child: Stack(
            children: [
              Container(
                width: cardSize,
                height: cardSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          imageFile!,
                          width: cardSize,
                          height: cardSize,
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: GestureDetector(
                  onTap: isUploading ? null : onTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: isUploading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.orange),
                          )
                        : Icon(Icons.camera_alt_outlined, color: iconColor, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 