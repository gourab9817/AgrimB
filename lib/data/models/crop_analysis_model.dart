// lib/data/models/crop_analysis_model.dart

class CropAnalysisModel {
  final int? totalSeeds;
  final int? healthySeeds;
  final int? defectiveSeeds;
  final String? error;
  final String? errorCode;

  CropAnalysisModel({
    this.totalSeeds,
    this.healthySeeds,
    this.defectiveSeeds,
    this.error,
    this.errorCode,
  });

  factory CropAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CropAnalysisModel(
      totalSeeds: json['total_seeds'] as int?,
      healthySeeds: json['healthy_seeds'] as int?,
      defectiveSeeds: json['defective_seeds'] as int?,
      error: json['error'] as String?,
      errorCode: json['error_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_seeds': totalSeeds,
      'healthy_seeds': healthySeeds,
      'defective_seeds': defectiveSeeds,
      'error': error,
      'error_code': errorCode,
    };
  }

  // Add the isSuccess getter
  bool get isSuccess => error == null && errorCode == null;
}

// Extension to convert error codes to user-friendly messages
extension ErrorCodeExtension on String {
  String get userFriendlyMessage {
    switch (this) {
      case 'E001':
        return 'Model initialization failed. Please try again later.';
      case 'E101':
        return 'No seeds detected in the image. Please ensure the image contains visible seeds.';
      case 'E201':
        return 'Objects in the image are too small to analyze properly.';
      case 'E202':
        return 'Objects in the image are too large to analyze properly.';
      case 'E203':
        return 'Objects in the image have inconsistent properties.';
      case 'E301':
        return 'Too few seeds detected. Please capture an image with more seeds.';
      case 'E999':
        return 'An error occurred during processing. Please try again.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }
}