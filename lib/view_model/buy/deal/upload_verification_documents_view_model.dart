import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/user_repository.dart';

class UploadVerificationDocumentsViewModel extends ChangeNotifier {
  File? contractImage;
  File? selfieImage;
  File? produceImage;

  String? contractUrl;
  String? selfieUrl;
  String? produceUrl;

  bool isContractUploading = false;
  bool isSelfieUploading = false;
  bool isProduceUploading = false;

  final ImagePicker _picker = ImagePicker();
  final UserRepository userRepository;
  final String claimedId;

  UploadVerificationDocumentsViewModel({required this.userRepository, required this.claimedId});

  Future<void> pickAndUploadContract(BuildContext context) async {
    await _showPicker(context, (source) async {
      isContractUploading = true;
      notifyListeners();
      final contractPicked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024, maxHeight: 1024);
      if (contractPicked != null) {
        contractImage = File(contractPicked.path);
        contractUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: contractImage!,
          docType: 'contract',
        );
      }
      isContractUploading = false;
      notifyListeners();
    });
  }

  Future<void> pickAndUploadSelfie(BuildContext context) async {
    await _showPicker(context, (source) async {
      isSelfieUploading = true;
      notifyListeners();
      final selfiePicked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024, maxHeight: 1024);
      if (selfiePicked != null) {
        selfieImage = File(selfiePicked.path);
        selfieUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: selfieImage!,
          docType: 'selfie',
        );
      }
      isSelfieUploading = false;
      notifyListeners();
    });
  }

  Future<void> pickAndUploadProduce(BuildContext context) async {
    await _showPicker(context, (source) async {
      isProduceUploading = true;
      notifyListeners();
      final producePicked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024, maxHeight: 1024);
      if (producePicked != null) {
        produceImage = File(producePicked.path);
        produceUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: produceImage!,
          docType: 'produce',
        );
      }
      isProduceUploading = false;
      notifyListeners();
    });
  }

  Future<void> _showPicker(BuildContext context, Function(ImageSource) onPick) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Click with Camera'),
              onTap: () {
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.brown),
              title: const Text('Select from Files'),
              onTap: () {
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.gallery);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void clearAll() {
    contractImage = null;
    selfieImage = null;
    produceImage = null;
    contractUrl = null;
    selfieUrl = null;
    produceUrl = null;
    isContractUploading = false;
    isSelfieUploading = false;
    isProduceUploading = false;
    notifyListeners();
  }

  Future<void> uploadAllSelectedImages(BuildContext context) async {
    bool anyUploading = false;
    try {
      if (contractImage != null && contractUrl == null) {
        isContractUploading = true;
        notifyListeners();
        contractUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: contractImage!,
          docType: 'contract',
        );
        isContractUploading = false;
        notifyListeners();
        anyUploading = true;
      }
      if (selfieImage != null && selfieUrl == null) {
        isSelfieUploading = true;
        notifyListeners();
        selfieUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: selfieImage!,
          docType: 'selfie',
        );
        isSelfieUploading = false;
        notifyListeners();
        anyUploading = true;
      }
      if (produceImage != null && produceUrl == null) {
        isProduceUploading = true;
        notifyListeners();
        produceUrl = await userRepository.uploadClaimedDealDoc(
          claimedId: claimedId,
          file: produceImage!,
          docType: 'produce',
        );
        isProduceUploading = false;
        notifyListeners();
        anyUploading = true;
      }
      // Update claimedlist with URLs and VisitStatus
      await userRepository.updateClaimedListWithDocs(
        claimedId: claimedId,
        signedContractUrl: contractUrl,
        selfieWithFarmerUrl: selfieUrl,
        finalProductPhotoUrl: produceUrl,
      );
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/deal-completed');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading images: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
} 