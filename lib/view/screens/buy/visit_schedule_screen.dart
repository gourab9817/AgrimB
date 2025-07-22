import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/listing_model.dart';
import '../../widgets/appbar/navbar.dart';
import 'package:provider/provider.dart';
import '../../../view_model/buy/visit_schedule_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../view/screens/buy/buy_screen.dart';
import '../../../routes/app_routes.dart';

class VisitScheduleScreen extends StatefulWidget {
  final ListingModel listing;
  const VisitScheduleScreen({Key? key, required this.listing}) : super(key: key);

  @override
  State<VisitScheduleScreen> createState() => _VisitScheduleScreenState();
}

class _VisitScheduleScreenState extends State<VisitScheduleScreen> {
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _fetchAndSetFarmerData();
  }

  Future<void> _fetchAndSetFarmerData() async {
    // Delay to ensure context is available
    await Future.delayed(Duration.zero);
    final visitScheduleVM = Provider.of<VisitScheduleViewModel>(context, listen: false);
    final farmer = await visitScheduleVM.userRepository.fetchFarmerDataById(widget.listing.farmerId);
    if (farmer != null) {
      setState(() {
        _nameController.text = farmer['name'] ?? '';
        _contactController.text = farmer['phoneNumber'] ?? '';
        _addressController.text = farmer['address'] ?? '';
        _locationController.text = farmer['location'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _selectedDateTime = dt;
        _dateTimeController.text = '${dt.day}/${dt.month}/${dt.year}  ${time.format(context)}';
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final visitScheduleVM = Provider.of<VisitScheduleViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.l10n('visit_schedule'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.l),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
              child: Container(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              listing.imagePath,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(context.l10n('quantity'), style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                                    Text('${listing.quantity} ${context.l10n('quintals')}', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(context.l10n('agreed_price'), style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                                    Text(context.l10n('price_per_quintal').replaceAll('{price}', listing.price.toString()), style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(context.l10n('quality_indicator'), style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                                    Text(listing.qualityIndicator, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(context.l10n('claimed_date'), style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                                    Text(context.l10n('march_1_2025'), style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(listing.name.toUpperCase(), style: AppTextStyle.bold20.copyWith(color: AppColors.brown)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildLabel(context.l10n('visit_date_time')),
                          _buildInputField(
                            controller: _dateTimeController,
                            hint: context.l10n('select_date_time'),
                            readOnly: true,
                            onTap: _pickDateTime,
                            suffixIcon: Icons.calendar_today,
                          ),
                          const SizedBox(height: 12),
                          _buildLabel(context.l10n('seller_contact')),
                          _buildInputField(controller: _contactController, hint: context.l10n('enter_contact')),
                          const SizedBox(height: 12),
                          _buildLabel(context.l10n('seller_name')),
                          _buildInputField(controller: _nameController, hint: context.l10n('enter_name')),
                          const SizedBox(height: 12),
                          _buildLabel(context.l10n('seller_address')),
                          _buildInputField(controller: _addressController, hint: context.l10n('enter_address')),
                          const SizedBox(height: 12),
                          _buildLabel(context.l10n('meeting_point')),
                          _buildInputField(controller: _locationController, hint: context.l10n('enter_location')),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.originalOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: visitScheduleVM.isLoading
                                  ? null
                                  : () async {
                                      if (_selectedDateTime == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(context.l10n('please_select_visit_datetime')), backgroundColor: AppColors.error),
                                        );
                                        return;
                                      }
                                      if (_locationController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(context.l10n('please_enter_meeting_point')), backgroundColor: AppColors.error),
                                        );
                                        return;
                                      }
                                      final firebaseUser = FirebaseAuth.instance.currentUser;
                                      final buyerId = firebaseUser?.uid ?? '';
                                      if (buyerId.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(context.l10n('user_not_logged_in')), backgroundColor: Colors.red),
                                        );
                                        return;
                                      }
                                      print('Current buyerId: $buyerId'); // Debug print
                                      await visitScheduleVM.scheduleVisit(
                                        farmerId: listing.farmerId,
                                        buyerId: buyerId,
                                        claimedDateTime: DateTime.now(),
                                        visitDateTime: _selectedDateTime!,
                                        listingId: listing.id,
                                        location: _locationController.text,
                                        cropName: listing.name,
                                        buyerName: FirebaseAuth.instance.currentUser?.displayName ?? 'Buyer',
                                      );
                                      if (visitScheduleVM.success) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.buy,
                                          (route) => false,
                                        );
                                        return;
                                      } else if (visitScheduleVM.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(visitScheduleVM.errorMessage!), backgroundColor: AppColors.error),
                                        );
                                      }
                                    },
                              child: visitScheduleVM.isLoading
                                  ? const CircularProgressIndicator(color: AppColors.brown)
                                  : Text(context.l10n('visit_schedule_button'), style: AppTextStyle.bold16.copyWith(color: AppColors.brown)),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTextStyle.regular16.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.grey, size: 20) : null,
      ),
    );
  }
} 