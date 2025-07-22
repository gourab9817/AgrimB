import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../view_model/buy/visit_site_reschedule_view_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../view_model/notification/notification_view_model.dart';

class VisitSiteRescheduleScreen extends StatelessWidget {
  final String claimedId;
  const VisitSiteRescheduleScreen({Key? key, required this.claimedId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisitSiteRescheduleViewModel(
        userRepository: Provider.of<UserRepository>(context, listen: false),
        notificationViewModel: Provider.of<NotificationViewModel>(context, listen: false),
      )..init(claimedId),
      child: const _VisitSiteRescheduleBody(),
    );
  }
}

class _VisitSiteRescheduleBody extends StatefulWidget {
  const _VisitSiteRescheduleBody({Key? key}) : super(key: key);
  @override
  State<_VisitSiteRescheduleBody> createState() => _VisitSiteRescheduleBodyState();
}

class _VisitSiteRescheduleBodyState extends State<_VisitSiteRescheduleBody> {
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _dateTimeController.dispose();
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
    final viewModel = Provider.of<VisitSiteRescheduleViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.l10n('reschedule_visit'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(18),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context.l10n('new_visit_date_time')),
                  _buildInputField(
                    controller: _dateTimeController,
                    hint: context.l10n('select_date_time'),
                    readOnly: true,
                    onTap: _pickDateTime,
                    suffixIcon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context.l10n('new_meeting_location')),
                  _buildInputField(controller: _locationController, hint: context.l10n('enter_new_location')),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              if (_selectedDateTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.l10n('please_select_new_visit_datetime')), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              if (_locationController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.l10n('please_enter_new_meeting_point')), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              await viewModel.rescheduleVisit(
                                newDateTime: _selectedDateTime!,
                                newLocation: _locationController.text,
                              );
                              if (viewModel.success) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/buy',
                                  (route) => false,
                                );
                                return;
                              } else if (viewModel.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: AppColors.error),
                                );
                              }
                            },
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : Text(context.l10n('update_visit'), style: AppTextStyle.bold16.copyWith(color: AppColors.white)),
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