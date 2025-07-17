import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class PhoneInput extends StatelessWidget {
  final void Function(String) onChanged;
  final String labelText;
  const PhoneInput({required this.onChanged, this.labelText = 'Phone Number', super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
        prefixText: '+91  ',
        hintText: labelText,
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
          return 'Please enter your phone number';
        }
        if (value.length != 10) {
          return 'Enter a valid 10-digit phone number';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
} 