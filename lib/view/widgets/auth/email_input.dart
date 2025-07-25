import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  const EmailInput({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: context.l10n('email'),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n('please_enter_email');
        }
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
          return context.l10n('please_enter_valid_email');
        }
        return null;
      },
    );
  }
} 