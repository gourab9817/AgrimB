import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class PhoneInput extends StatelessWidget {
  final void Function(String) onChanged;
  final String labelText;
  const PhoneInput({required this.onChanged, this.labelText = 'Phone Number', super.key});

  @override
  Widget build(BuildContext context) {
    // Use localized label text if it matches the default, otherwise use the provided label
    final hintText = labelText == 'Phone Number' 
        ? context.l10n('phone_number')
        : labelText;

    return TextFormField(
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
        prefixText: '+91  ',
        hintText: hintText,
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
          return context.l10n('please_enter_phone_number');
        }
        if (value.length != 10) {
          return context.l10n('enter_valid_10_digit_phone');
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
} 