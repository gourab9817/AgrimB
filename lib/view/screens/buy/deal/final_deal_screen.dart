import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widgets/Button/app_button.dart';
import '../../../../view_model/buy/deal/final_deal_view_model.dart';
import 'package:flutter/services.dart';

class FinalDealScreen extends StatelessWidget {
  final String claimedId;
  const FinalDealScreen({Key? key, required this.claimedId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FinalDealViewModel(userRepository: Provider.of(context, listen: false))..fetchDealData(claimedId),
      child: const _FinalDealBody(),
    );
  }
}

class _FinalDealBody extends StatelessWidget {
  const _FinalDealBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FinalDealViewModel>(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 500;
    final data = viewModel.dealData;
    final isLoading = viewModel.isLoading;
    final error = viewModel.errorMessage;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Final Deal Price', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.orange)
            : error != null
                ? Text(error, style: AppTextStyle.bold16.copyWith(color: AppColors.error))
                : data == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 400 : width * 0.98,
                            minWidth: 280,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text('Agent Input', style: AppTextStyle.bold18.copyWith(color: AppColors.orange)),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoBox(
                                        label: 'Farmer',
                                        value: data['farmerName'] ?? '-',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _InfoBox(
                                        label: 'Crop',
                                        value: data['cropName'] ?? '-',
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _DealInputField(
                                  label: 'Final deal price',
                                  controller: viewModel.finalDealPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                const SizedBox(height: 16),
                                _DealInputField(
                                  label: 'Farmer Aadhaar Number',
                                  controller: viewModel.aadhaarController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                const SizedBox(height: 16),
                                _DealInputField(
                                  label: 'Delivery Location',
                                  controller: viewModel.locationController,
                                ),
                                const SizedBox(height: 16),
                                _DealInputField(
                                  label: 'Delivery date',
                                  controller: viewModel.deliveryDateController,
                                  readOnly: true,
                                  onTap: () => viewModel.pickDeliveryDate(context),
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonWidth = constraints.maxWidth > 320 ? 320 : constraints.maxWidth;
                                      return ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 320,
                                          minHeight: 48,
                                        ),
                                        child: ElevatedButton(
                                          onPressed: viewModel.isSubmitting ? null : () {
                                            viewModel.submitFinalDeal(context, (context.findAncestorWidgetOfExactType<FinalDealScreen>() as FinalDealScreen).claimedId);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.orange.withOpacity(0.9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            elevation: 4,
                                            shadowColor: AppColors.orange.withOpacity(0.18),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: viewModel.isSubmitting
                                              ? const SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                                )
                                              : FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: const Text(
                                                    'Finalize Deal',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _InfoBox({required this.label, required this.value, this.isBold = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
          const SizedBox(height: 2),
          Text(
            value,
            style: isBold
                ? AppTextStyle.bold16.copyWith(color: AppColors.brown)
                : AppTextStyle.medium14.copyWith(color: AppColors.brown),
          ),
        ],
      ),
    );
  }
}

class _DealInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _DealInputField({required this.label, required this.controller, this.readOnly = false, this.onTap, this.keyboardType, this.inputFormatters, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.medium14.copyWith(color: AppColors.orange)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyle.regular16.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
} 