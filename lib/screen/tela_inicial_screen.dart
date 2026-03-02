import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fire_app/screen/widget_tree.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  State<TelaInicialScreen> createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  @override
  void initState() {
    super.initState();

    // Timer de Splash
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WidgetTree()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // 🔥 vermelho oficial
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO CENTRAL
            Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
            ),

            const SizedBox(height: 24),

            /// Nome do App estilizado pelo Design System
            Text(
              'FireApp',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.darkText, // preto 010207 do Figma
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
