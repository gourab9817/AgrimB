// lib/data/services/crop_analysis_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:AgrimSeller/data/models/crop_analysis_model.dart';
import 'package:agrimb/data/models/crop_analysis_model.dart';

class CropAnalysisService {
  static const String _baseUrl = 'https://wheat-seed-api-345895348005.us-central1.run.app';
  static const String _analyzeSeedsEndpoint = '/analyze-seeds';
  
  Future<CropAnalysisModel> analyzeCrop(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl$_analyzeSeedsEndpoint');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      // Send request and get response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parse response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CropAnalysisModel.fromJson(responseData);
      } else {
        // Handle non-200 status codes
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      return CropAnalysisModel(
        error: 'Failed to analyze crop',
        errorCode: 'E999',
      );
    }
  }
}