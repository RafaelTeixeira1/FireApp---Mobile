import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// Tema claro (padrão)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,

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

      // AppBar configurada com tema claro
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),

      // Input decorations
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.white.withValues(alpha: 0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white70),
        ),
        labelStyle: const TextStyle(color: AppColors.white70),
        hintStyle: const TextStyle(color: AppColors.white70),
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

  /// Tema escuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1A1A2E), // Cor primária escura para temas escuros

      // 🌙 Cores de fundo escuras
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      canvasColor: AppColors.darkSurface,

      // 🔠 Fonte global do app
      fontFamily: 'Poppins',

      // Desabilita o splash azul padrão do Android
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // 🔳 Estilo padrão dos botões do app
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.darkBorder),
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // AppBar personalizada para tema escuro
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),

      // Input decorations para tema escuro
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkCard,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        labelStyle: const TextStyle(color: AppColors.darkGreyText),
        hintStyle: const TextStyle(color: AppColors.darkGreyText),
      ),

      // 🔤 Texto padrão
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.lightText),
        bodyLarge: TextStyle(color: AppColors.lightText),
        labelLarge: TextStyle(color: AppColors.lightText),

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
          color: AppColors.lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Ícones
      iconTheme: const IconThemeData(color: AppColors.lightText),
    );
  }

  /// Para manter compatibilidade com código existente
  static ThemeData get theme => lightTheme;
}
