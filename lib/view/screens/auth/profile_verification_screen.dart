import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/auth/app_button.dart';
import '../../../routes/app_routes.dart';
import '../../../view_model/auth/profile_verification_view_model.dart';
import '../../widgets/popup/custom_notification.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileVerificationScreen extends StatelessWidget {
  const ProfileVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileVerificationViewModel>(
      create: (context) => ProfileVerificationViewModel(
        userRepository: Provider.of<UserRepository>(context, listen: false),
      )..loadUser(),
      child: const _ProfileVerificationBody(),
    );
  }
}

class _ProfileVerificationBody extends StatelessWidget {
  const _ProfileVerificationBody({Key? key}) : super(key: key);

  Future<void> _handleRefresh(BuildContext context) async {
    final viewModel = Provider.of<ProfileVerificationViewModel>(context, listen: false);
    final verified = await viewModel.checkVerification();
    if (verified) {
      CustomNotification.showSuccess(
        context: context,
        message: 'Your profile has been verified! Redirecting...'
      );
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      CustomNotification.showInfo(
        context: context,
        message: 'Your profile is not verified yet. Please try again later.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileVerificationViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text('Account Verification', style: TextStyle(color: AppColors.brown)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        const Icon(Icons.verified_user, size: 100, color: AppColors.orange),
                        const SizedBox(height: 32),
                        const Text(
                          'Your account is under verification',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brown),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thank you for signing up!\nOur team is reviewing your details. You will be notified once your profile is verified.\n\nYou cannot access the app until verification is complete.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        BasicAppButton(
                          title: viewModel.isChecking ? 'Checking...' : 'Check Verification',
                          onPressed: viewModel.isChecking
                              ? null
                              : () async {
                                  final verified = await viewModel.checkVerification();
                                  if (verified) {
                                    CustomNotification.showSuccess(
                                      context: context,
                                      message: 'Your profile has been verified! Redirecting...'
                                    );
                                    await Future.delayed(const Duration(seconds: 1));
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                                    }
                                  } else {
                                    CustomNotification.showInfo(
                                      context: context,
                                      message: 'Your profile is not verified yet. Please try again later.',
                                    );
                                  }
                                },
                          backgroundColor: AppColors.brown,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Pull down to refresh and check verification status.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 