import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label acima do campo
        Text(label, style: AppTextStyles.label),

        const SizedBox(height: 6),

        // Campo de texto
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles.body, // texto branco
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelHint, // branco 70%

            filled: true,
            fillColor: AppColors.white10, // fundo com leve transparência

            border: InputBorder.none, // sem borda
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,

            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
          ),
        ),
      ],
    );
  }
}
