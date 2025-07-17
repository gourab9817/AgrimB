import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/email_input.dart';
import '../../widgets/auth/password_input.dart';
import '../../widgets/auth/error_dialog.dart';
import '../../widgets/auth/app_button.dart';
import '../../../view_model/auth/login_view_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

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
                    title: 'Welcome Back!',
                    subtitle: 'Sign in to continue to your account',
                  ),
                  EmailInput(controller: _emailController),
                  const SizedBox(height: 16),
                  PasswordInput(controller: _passwordController),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BasicAppButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final user = await viewModel.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
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
                    title: viewModel.isLoading ? 'Logging In...' : 'Login',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: AppColors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Create Account', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
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