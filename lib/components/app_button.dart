import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined ? _outlinedButton() : _filledButton(),
    );
  }

  // 🔴 BOTÃO PRINCIPAL (background preto com texto branco)
  Widget _filledButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? AppColors.grey
            : AppColors.darkText, // Preto 010207
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Text(
        text,
        style: AppTextStyles.buttonPrimary.copyWith(color: AppColors.white),
      ),
    );
  }

  // ⚪ BOTÃO SECUNDÁRIO (borda branca, fundo transparente)
  Widget _outlinedButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isDisabled ? AppColors.grey : AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.transparent,
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Text(
        text,
        style: AppTextStyles.buttonSecondary.copyWith(
          color: isDisabled ? AppColors.grey : AppColors.white,
        ),
      ),
    );
  }
}
