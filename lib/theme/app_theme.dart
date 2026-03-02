import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: false,

      // 🖤 Define a cor de fundo principal do app
      scaffoldBackgroundColor: AppColors.primary,

      // 🔠 Fonte global do app
      fontFamily: 'Poppins',

      // Desabilita o splash azul padrão do Android
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // 🔳 Estilo padrão dos botões do app
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkText,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.white),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // 🔤 Texto padrão
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.white),
        bodyLarge: TextStyle(color: AppColors.white),
        labelLarge: TextStyle(color: AppColors.white),

        // Titulos
        titleLarge: TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
