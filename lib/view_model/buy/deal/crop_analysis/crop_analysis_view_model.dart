// import 'package:flutter/material.dart';
// import '../../../../../data/services/crop_analysis_service.dart';
// import '../../../../../data/models/crop_analysis_model.dart';

// class CropAnalysisViewModel extends ChangeNotifier {
//   final String claimedId;
//   final CropAnalysisService _service = CropAnalysisService();

//   bool isLoading = false;
//   String? errorMessage;
//   CropAnalysisModel? analysisResult;

//   CropAnalysisViewModel({required this.claimedId}) {
//     fetchAnalysis();
//   }

//   Future<void> fetchAnalysis() async {
//     isLoading = true;
//     errorMessage = null;
//     analysisResult = null;
//     notifyListeners();
//     try {
//       analysisResult = await _service.getAnalysisForClaimedId(claimedId);
//     } catch (e) {
//       errorMessage = 'Failed to fetch analysis: $e';
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// } 