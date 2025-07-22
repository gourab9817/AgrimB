import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/email_input.dart';
import '../../widgets/auth/password_input.dart';
import '../../widgets/auth/phone_input.dart';
import '../../widgets/auth/error_dialog.dart';
import '../../widgets/auth/app_button.dart';
import '../../../view_model/auth/signup_view_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();
  String _phoneNumber = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);

    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorDialog.show(
          context,
          message: viewModel.errorMessage!,
          onDismiss: viewModel.resetError,
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      AppAssets.app_icon,
                      width: MediaQuery.of(context).size.width * 0.28,
                      height: MediaQuery.of(context).size.width * 0.28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthHeader(
                    title: context.l10n('create_account'),
                    subtitle: context.l10n('fill_details_to_start'),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: context.l10n('full_name'),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? context.l10n('please_enter_name') : null,
                  ),
                  const SizedBox(height: 16),
                  EmailInput(controller: _emailController),
                  const SizedBox(height: 16),
                  PhoneInput(
                    onChanged: (value) => _phoneNumber = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: context.l10n('address'),
                      prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? context.l10n('please_enter_address') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: InputDecoration(
                      hintText: context.l10n('id_number'),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? context.l10n('please_enter_id') : null,
                  ),
                  const SizedBox(height: 16),
                  PasswordInput(controller: _passwordController),
                  const SizedBox(height: 16),
                  PasswordInput(controller: _confirmPasswordController, hintText: context.l10n('confirm_password')),
                  const SizedBox(height: 24),
                  BasicAppButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.l10n('passwords_dont_match')), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (_phoneNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.l10n('please_enter_phone')), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              final user = await viewModel.signup(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                name: _nameController.text.trim(),
                                phoneNumber: _phoneNumber,
                                address: _addressController.text.trim(),
                                idNumber: _idNumberController.text.trim(),
                              );
                              if (user != null && mounted) {
                                if (user.profileVerified) {
                                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                                } else {
                                  Navigator.pushReplacementNamed(context, AppRoutes.profileVerification);
                                }
                              }
                            }
                          },
                    title: viewModel.isLoading ? context.l10n('creating_account') : context.l10n('create_account'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.l10n('already_have_account'), style: const TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: Text(context.l10n('login'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ],
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