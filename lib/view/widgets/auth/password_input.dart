import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  const PasswordInput({required this.controller, this.hintText = 'Password', super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Use localized hint text if it matches common password keys, otherwise use the provided hint
    String getHintText() {
      switch (widget.hintText.toLowerCase()) {
        case 'password':
          return context.l10n('password');
        case 'confirm password':
          return context.l10n('confirm_password');
        case 'new password':
          return context.l10n('new_password');
        case 'current password':
          return context.l10n('current_password');
        default:
          return widget.hintText;
      }
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: getHintText(),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n('please_enter_password');
        }
        if (value.length < 6) {
          return context.l10n('password_must_be_at_least_6');
        }
        return null;
      },
    );
  }
} 