import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../routes/app_routes.dart';
import 'dart:async';

class DealCompletedSplashScreen extends StatefulWidget {
  const DealCompletedSplashScreen({Key? key}) : super(key: key);

  @override
  State<DealCompletedSplashScreen> createState() => _DealCompletedSplashScreenState();
}

class _DealCompletedSplashScreenState extends State<DealCompletedSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.buy, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: width * 0.18 + 40,
              height: width * 0.18 + 40,
              decoration: BoxDecoration(
                color: AppColors.brown.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified, color: AppColors.brown, size: width * 0.12 + 32),
            ),
            const SizedBox(height: 32),
            Text(
              'Deal\nCompleted\nSuccessfully\nBuyed',
              textAlign: TextAlign.center,
              style: AppTextStyle.bold20.copyWith(color: AppColors.brown, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
} 