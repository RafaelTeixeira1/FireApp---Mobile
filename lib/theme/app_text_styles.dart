import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // *** TÍTULOS ***
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // *** SUBTÍTULOS / LABELS ***
  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Utilizado nos campos de texto (placeholder)
  static const TextStyle labelHint = TextStyle(
    fontFamily: "Poppins",
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white70,
  );

  // *** CORPO DO TEXTO ***
  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    color: AppColors.white,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: AppColors.white,
  );

  // *** ERROS ***
  static const TextStyle error = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.red,
  );

  // *** BOTÕES ***
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
}
