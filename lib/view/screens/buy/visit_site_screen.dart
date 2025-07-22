import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../view/widgets/appbar/navbar.dart';
import '../../../view_model/buy/visit_site_view_model.dart';
import 'visit_site_reschedule_screen.dart';
import '../../../view/widgets/popup/universal_confirmation_dialog.dart';
import '../../../core/constants/app_assets.dart';
import 'visit_site_on_site_options_screen.dart';
import '../../../main.dart';
import '../../../view_model/notification/notification_view_model.dart';

class VisitSiteScreen extends StatefulWidget {
  final String claimedId;
  const VisitSiteScreen({Key? key, required this.claimedId}) : super(key: key);

  @override
  State<VisitSiteScreen> createState() => _VisitSiteScreenState();
}

class _VisitSiteScreenState extends State<VisitSiteScreen> with RouteAware {
  late VisitSiteViewModel viewModel;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      viewModel = VisitSiteViewModel(
        userRepository: Provider.of(context, listen: false),
        notificationViewModel: Provider.of<NotificationViewModel>(context, listen: false),
      );
      viewModel.fetchVisitSiteData(widget.claimedId);
      _initialized = true;
    }
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    viewModel.fetchVisitSiteData(widget.claimedId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VisitSiteViewModel>.value(
      value: viewModel,
      child: _VisitSiteBody(claimedId: widget.claimedId),
    );
  }
}

class _VisitSiteBody extends StatelessWidget {
  final String claimedId;
  const _VisitSiteBody({Key? key, required this.claimedId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VisitSiteViewModel>(context);
    final width = MediaQuery.of(context).size.width;
    final data = viewModel.visitSiteData;
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
        title: Text(context.l10n('visit_site'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final contentWidth = isWide ? 600.0 : (constraints.maxWidth * 0.98);
          return Center(
            child: isLoading
                ? const CircularProgressIndicator(color: AppColors.orange)
                : error != null
                    ? Text(error, style: AppTextStyle.bold16.copyWith(color: AppColors.error))
                    : data == null
                        ? const SizedBox.shrink()
                        : RefreshIndicator(
                            onRefresh: () async {
                              await viewModel.fetchVisitSiteData(claimedId);
                            },
        child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                                  maxWidth: contentWidth,
              minWidth: 280,
            ),
            child: Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: isWide ? 32 : 16,
                                    horizontal: isWide ? 24 : 0,
                                  ),
                                  padding: EdgeInsets.all(isWide ? 32 : 18),
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
                                  child: _VisitSiteDetails(data: data),
                                ),
                              ),
                            ),
                          ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

class _VisitSiteDetails extends StatelessWidget {
  final Map<String, dynamic> data;
  const _VisitSiteDetails({required this.data});

  @override
  Widget build(BuildContext context) {
    final crop = data['crop'] ?? {};
    final farmer = data['farmer'] ?? {};
    final claimed = data['claimed'] ?? {};
    final viewModel = Provider.of<VisitSiteViewModel>(context);
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                crop['imagePath'] ?? '',
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(context.l10n('quantity'), style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                                Text('${crop['quantity'] ?? '-'} ${context.l10n('quintals')}', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(context.l10n('agreed_price'), style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                                Text(context.l10n('price_per_quintal').replaceAll('{price}', (crop['price'] ?? '-').toString()), style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(context.l10n('quality_indicator'), style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                      Text(crop['qualityIndicator'] ?? '-', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(context.l10n('claimed_date'), style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                      Text((claimed['claimedDateTime'] ?? '').toString().split('T').first, style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
            (crop['name'] ?? '-').toString().toUpperCase(),
                      style: AppTextStyle.bold20.copyWith(color: AppColors.brown),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLabel(context.l10n('visit_date_time')),
        _buildReadOnlyField(claimed['visitDateTime'] ?? '-'),
                  const SizedBox(height: 12),
        _buildLabel(context.l10n('farmers_contact')),
        _buildReadOnlyField(farmer['phoneNumber'] ?? '-'),
                  const SizedBox(height: 12),
        _buildLabel(context.l10n('farmers_name')),
        _buildReadOnlyField(farmer['name'] ?? '-'),
                  const SizedBox(height: 12),
        _buildLabel(context.l10n('farmers_address')),
        _buildReadOnlyField(farmer['address'] ?? '-'),
                  const SizedBox(height: 12),
        _buildLabel(context.l10n('meeting_point')),
        _buildReadOnlyField(claimed['location'] ?? '-'),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 420;
                      if (isWide) {
                        // Row layout for wide screens
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            SizedBox(
                              width: 180,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.lightOrange,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => UniversalConfirmationDialog(
                                      animationAsset: AppAssets.exclamation,
                                      message: context.l10n('reschedule_visit_confirmation'),
                                      yesText: context.l10n('yes'),
                                      noText: context.l10n('no'),
                                      onYes: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => VisitSiteRescheduleScreen(claimedId: data['claimed']['id']),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(context.l10n('visit_reschedule'), style: AppTextStyle.bold18.copyWith(color: AppColors.orange)),
                              ),
                            ),
                            const SizedBox(width: 30),
                            SizedBox(
                              width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VisitSiteOnSiteOptionsScreen(claimedId: data['claimed']['id']),
                                    ),
                                  );
                                },
                                child: Text(context.l10n('i_am_on_site'), style: AppTextStyle.bold18.copyWith(color: AppColors.white)),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Column layout for small screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.lightOrange,
                                  side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => UniversalConfirmationDialog(
                                      animationAsset: AppAssets.exclamation,
                                      message: context.l10n('reschedule_visit_confirmation'),
                                      yesText: context.l10n('yes'),
                                      noText: context.l10n('no'),
                                      onYes: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => VisitSiteRescheduleScreen(claimedId: data['claimed']['id']),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(context.l10n('visit_reschedule'), style: AppTextStyle.bold18.copyWith(color: AppColors.orange)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VisitSiteOnSiteOptionsScreen(claimedId: data['claimed']['id']),
                                    ),
                                  );
                                },
                                child: Text(context.l10n('i_am_on_site'), style: AppTextStyle.bold18.copyWith(color: AppColors.white)),
                        ),
                      ),
                    ],
                        );
                      }
                    },
                  ),
        const SizedBox(height: 40),
                  Center(
          child: SizedBox(
            width: 260,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1.2),
                        shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: viewModel.isCancelLoading
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => UniversalConfirmationDialog(
                          animationAsset: AppAssets.exclamation,
                          message: context.l10n('cancel_visit_confirmation'),
                          yesText: context.l10n('yes'),
                          noText: context.l10n('no'),
                          onYes: () async {
                            final claimedId = data['claimed']['id'];
                            final success = await viewModel.cancelVisit(claimedId);
                            if (success) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/buy',
                                (route) => false,
                              );
                              return;
                            } else if (viewModel.cancelError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(viewModel.cancelError!), backgroundColor: AppColors.error),
                              );
                            }
                          },
                        ),
                      );
                    },
              child: Text(context.l10n('cancel_visit'), style: AppTextStyle.bold18.copyWith(color: AppColors.error)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      style: AppTextStyle.regular16.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}