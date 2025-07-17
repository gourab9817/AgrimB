import 'package:flutter/material.dart';
import 'app_assets.dart';

class AppTextStyle {
  // Regular Text Styles
  static TextStyle regular10 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle regular12 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle regular14 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle regular16 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  // Medium Text Styles
  static TextStyle medium12 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle medium14 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle medium16 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle medium18 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  // Bold Text Styles
  static TextStyle bold14 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bold16 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bold18 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bold20 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bold24 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Black Text Styles (Extra Bold)
  static TextStyle black20 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w900,
  );

  static TextStyle black24 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static TextStyle black32 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );

  // Light Text Styles
  static TextStyle light12 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  static TextStyle light14 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  static TextStyle light16 = TextStyle(
    fontFamily: AppAssets.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w300,
  );

  // Helper methods for common text styles with colors
  static TextStyle get heading => bold24.copyWith(
        color: Colors.black,
        height: 1.2,
      );

  static TextStyle get subheading => medium18.copyWith(
        color: Colors.black87,
        height: 1.3,
      );

  static TextStyle get body => regular16.copyWith(
        color: Colors.black87,
        height: 1.5,
      );

  static TextStyle get caption => regular12.copyWith(
        color: Colors.black54,
        height: 1.4,
      );

  static TextStyle get button => medium16.copyWith(
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get label => medium14.copyWith(
        color: Colors.black87,
        height: 1.2,
      );

  static TextStyle get error => regular12.copyWith(
        color: Colors.red,
        height: 1.2,
      );

  static TextStyle get success => regular12.copyWith(
        color: Colors.green,
        height: 1.2,
      );
}
