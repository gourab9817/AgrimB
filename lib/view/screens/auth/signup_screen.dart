import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
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
                  const AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Fill in your details to get started',
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
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
                      hintText: 'Address',
                      prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: InputDecoration(
                      hintText: 'ID Number',
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your ID number' : null,
                  ),
                  const SizedBox(height: 16),
                  PasswordInput(controller: _passwordController),
                  const SizedBox(height: 16),
                  PasswordInput(controller: _confirmPasswordController, hintText: 'Confirm Password'),
                  const SizedBox(height: 24),
                  BasicAppButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (_phoneNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid phone number'), backgroundColor: Colors.red),
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
                    title: viewModel.isLoading ? 'Creating Account...' : 'Create Account',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: const Text('Login', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
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