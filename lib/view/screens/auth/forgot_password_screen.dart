import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/email_input.dart';
import '../../widgets/auth/error_dialog.dart';
import '../../widgets/auth/app_button.dart';
import '../../../view_model/auth/forgot_password_view_model.dart';
import '../../../routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ForgotPasswordViewModel>(context);

    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorDialog.show(
          context,
          message: viewModel.errorMessage!,
          onDismiss: viewModel.reset,
        );
      });
    }

    if (viewModel.isEmailSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(context.l10n('email_sent'), style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
            content: Text(context.l10n('password_reset_instructions')),
            actions: [
              TextButton(
                onPressed: () {
                  viewModel.reset();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: Text(context.l10n('back_to_login'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
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
                  AuthHeader(
                    title: context.l10n('forgot_password_title'),
                    subtitle: context.l10n('enter_email_to_reset'),
                  ),
                  EmailInput(controller: _emailController),
                  const SizedBox(height: 32),
                  BasicAppButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await viewModel.resetPassword(_emailController.text.trim());
                            }
                          },
                    title: viewModel.isLoading ? context.l10n('sending') : context.l10n('reset_password'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: Text(context.l10n('back_to_login'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
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