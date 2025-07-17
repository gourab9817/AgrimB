//lib/view/screens/profile/profile_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import 'package:agrimb/core/constants/app_spacing.dart';
import 'package:agrimb/core/constants/app_text_style.dart';
import 'package:agrimb/view/widgets/appbar/navbar.dart';
import 'package:agrimb/view/widgets/Button/app_button.dart';
import 'package:agrimb/view/widgets/popup/custom_notification.dart';

import 'package:agrimb/view_model/profile/profile_view_model.dart';
import 'package:agrimb/routes/app_routes.dart';
import 'package:agrimb/view/screens/profile/photo_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _loadingAnimationController;
  
  @override
  void initState() {
    super.initState();
    // Animation controller for loading animations
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Fetch user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserData();
    });
  }
  
  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      
      // Don't allow new uploads if one is in progress
      if (viewModel.isUploadingProfilePicture) {
        return;
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (image != null) {
        // Show the photo view screen
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewScreen(imagePath: image.path),
            ),
          );
          
          // If the user confirmed the image
          if (result == true && mounted) {
            final success = await viewModel.uploadProfilePicture(File(image.path));
            
            if (success && mounted) {
              CustomNotification.showSuccess(
                context: context,
                message: 'Your profile picture has been updated successfully.',
                title: 'Profile Updated',
              );
            } else if (mounted) {
              CustomNotification.showError(
                context: context,
                message: 'Failed to update profile picture. Please try again.',
                title: 'Update Failed',
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.showError(
          context: context,
          message: 'Error selecting image: $e',
          title: 'Error',
        );
      }
    }
  }
  
  Future<void> _takeProfilePicture() async {
    try {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      
      // Don't allow new uploads if one is in progress
      if (viewModel.isUploadingProfilePicture) {
        return;
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, 
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (image != null) {
        // Show the photo view screen
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewScreen(imagePath: image.path),
            ),
          );
          
          // If the user confirmed the image
          if (result == true && mounted) {
            final success = await viewModel.uploadProfilePicture(File(image.path));
            
            if (success && mounted) {
              CustomNotification.showSuccess(
                context: context,
                message: 'Your profile picture has been updated successfully.',
                title: 'Profile Updated',
              );
            } else if (mounted) {
              CustomNotification.showError(
                context: context,
                message: 'Failed to update profile picture. Please try again.',
                title: 'Update Failed',
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.showError(
          context: context,
          message: 'Error taking photo: $e',
          title: 'Error',
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _takeProfilePicture();
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.lightOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.orange,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gallery option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _uploadProfilePicture();
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.lightOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: AppColors.orange,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Apply AppBar with correct styling
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.originalOrange,
        automaticallyImplyLeading: false, // Remove default back button
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with profile photo and name
                  _buildProfileHeader(viewModel, size),
                  const SizedBox(height: 16),
                  // User details section
                  _buildUserDetailsSection(viewModel),
                  const SizedBox(height: 24),
                  // Settings and options
                  _buildSettingsSection(viewModel, context),
                  const SizedBox(height: 80), // Space for bottom nav bar
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3, // Profile tab
        
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel, Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.originalOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile image
          GestureDetector(
            onTap: viewModel.isUploadingProfilePicture ? null : _showImagePickerOptions,
            child: Stack(
              children: [
                // Profile image or initials
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white,
                  ),
                  child: viewModel.isUploadingProfilePicture
                      ? _buildInteractiveLoadingAnimation(viewModel)
                      : (viewModel.user?.profilePictureUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                viewModel.user!.profilePictureUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      _getInitials(viewModel.user?.name ?? ''),
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brown,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.originalOrange,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                _getInitials(viewModel.user?.name ?? ''),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brown,
                                ),
                              ),
                            )),
                ),
                // Camera icon (hidden during upload)
                if (!viewModel.isUploadingProfilePicture)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.brown,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            viewModel.user?.name ?? 'Farmer',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            viewModel.user?.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  // Interactive loading animation for profile picture upload
  Widget _buildInteractiveLoadingAnimation(ProfileViewModel viewModel) {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle with rotating gradient
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: 0,
                  endAngle: math.pi * 2,
                  colors: [
                    AppColors.orange.withOpacity(0.2),
                    AppColors.orange,
                    AppColors.orange.withOpacity(0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: GradientRotation(_loadingAnimationController.value * math.pi * 2),
                ),
              ),
            ),
            
            // Circular progress indicator showing actual progress
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: viewModel.uploadProgress,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brown),
              ),
            ),
            
            // Inner white circle
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              // Show percentage text
              child: Center(
                child: Text(
                  '${(viewModel.uploadProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),
            
            // Optional: Add animated dots to indicate activity
            if (viewModel.uploadProgress < 0.9)
              Positioned(
                bottom: 20,
                child: _buildAnimatedDots(),
              ),
          ],
        );
      },
    );
  }
  
  // Animated dots to indicate activity
  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        // Calculate dot opacity based on animation value
        final double dot1Opacity = _calculateDotOpacity(0);
        final double dot2Opacity = _calculateDotOpacity(0.33);
        final double dot3Opacity = _calculateDotOpacity(0.66);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(dot1Opacity),
            const SizedBox(width: 4),
            _buildDot(dot2Opacity),
            const SizedBox(width: 4),
            _buildDot(dot3Opacity),
          ],
        );
      },
    );
  }
  
  Widget _buildDot(double opacity) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brown.withOpacity(opacity),
      ),
    );
  }
  
  double _calculateDotOpacity(double offset) {
    // Create pulsating effect based on animation value
    final double pulseValue = (_loadingAnimationController.value + offset) % 1.0;
    // Return smooth sine wave opacity value between 0.3 and 1.0
    return 0.3 + 0.7 * math.sin(pulseValue * math.pi);
  }

  Widget _buildUserDetailsSection(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 16),
          // Phone number
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: viewModel.user?.phoneNumber ?? 'Not provided',
          ),
          const SizedBox(height: 12),
          // Address
          _buildInfoItem(
            icon: Icons.home_outlined,
            title: 'Address',
            value: viewModel.user?.address ?? 'Not provided',
          ),
          const SizedBox(height: 12),
          // ID Number
          _buildInfoItem(
            icon: Icons.badge_outlined,
            title: 'ID Number',
            value: viewModel.user?.idNumber ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 16),
          // Edit Profile Option
          _buildSettingItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              // Show coming soon notification
              CustomNotification.showComingSoon(
                context: context,
                title: 'Edit Profile',
                message: 'The Edit Profile feature will be available in the next update!',
              );
            },
          ),
          const SizedBox(height: 12),
          // Language Option
          _buildSettingItem(
            icon: Icons.language_outlined,
            title: 'Change Language',
            onTap: () {
              // Show coming soon notification
              CustomNotification.showComingSoon(
                context: context,
                title: 'Change Language',
                message: 'Additional language options will be available soon!',
              );
            },
          ),
          const SizedBox(height: 12),
          // Help & Support
          _buildSettingItem(
            icon: Icons.help_outline_outlined,
            title: 'Help & Support',
            onTap: () {
              // Show coming soon notification
              CustomNotification.showComingSoon(
                context: context,
                title: 'Help & Support',
                message: 'Our support center is under construction and will be available soon!',
              );
            },
          ),
          const SizedBox(height: 24),
          // Logout Button
          Center(  // Added this Center widget to center the button
            child: BasicAppButton(
              onPressed: viewModel.isLoggingOut
                ? null
                : () async {
                  bool confirmed = await _showLogoutConfirmationDialog(context);
                  if (confirmed && mounted) {
                    await viewModel.logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  }
                },
              title: viewModel.isLoggingOut ? 'Logging out...' : 'Logout',
              backgroundColor: const Color.fromARGB(255, 241, 40, 10),
              textColor: const Color.fromARGB(255, 255, 255, 255),
              height: 50,
              width: 125,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: 10),
              // Message
              const Text(
                'Are you sure you want to logout from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.orange),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Logout button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
  }
}