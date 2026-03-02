import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/app_input.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final TextEditingController _emailController = TextEditingController();
  String? _mensagem;

  Future<void> _enviarEmailRecuperacao() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      setState(() {
        _mensagem = "E-mail de recuperação enviado!";
      });
    } catch (e) {
      setState(() {
        _mensagem = "Não foi possível enviar o e-mail.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              /// LOGO
              Image.asset(
                "assets/logo.png",
                width: 120,
              ),

              const SizedBox(height: 40),

              /// TÍTULO
              Text(
                "Recuperar Senha",
                style: AppTextStyles.titleMedium,
              ),

              const SizedBox(height: 16),

              Text(
                "Informe o seu e-mail para enviarmos um link\nde recuperação de senha.",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /// CAMPO DE EMAIL
              AppInput(
                label: "",
                hint: "Digite seu e-mail",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              /// BOTÃO ENVIAR
              AppButton(
                text: "Enviar link",
                onPressed: _enviarEmailRecuperacao,
              ),

              const SizedBox(height: 20),

              /// MENSAGEM DE FEEDBACK
              if (_mensagem != null)
                Text(
                  _mensagem!,
                  style: AppTextStyles.bodyBold,
                ),

              const SizedBox(height: 30),

              /// VOLTAR AO LOGIN
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.loginRegister);
                },
                child: Text(
                  "Voltar ao login",
                  style: AppTextStyles.bodyBold.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
