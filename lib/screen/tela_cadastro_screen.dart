import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/app_input.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // Controllers
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _dataNasc = TextEditingController();
  final TextEditingController _cpf = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  bool _isLoading = false;
  DateTime? _dataSelecionada;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _dataNasc.dispose();
    _cpf.dispose();
    _senha.dispose();
    _confirmarSenha.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final nome = _nome.text.trim();
    final email = _email.text.trim();
    final senha = _senha.text.trim();
    final confirmar = _confirmarSenha.text.trim();
    final cpf = _cpf.text.trim();

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmar.isEmpty ||
        _dataNasc.text.isEmpty ||
        cpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_emailValido(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data de nascimento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dataSelecionada!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data de nascimento não pode ser futura'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final idade = DateTime.now().difference(_dataSelecionada!).inDays ~/ 365;
    if (idade < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('É necessário ter pelo menos 13 anos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cpfErro = _validarCpf(cpf);
    if (cpfErro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cpfErro), backgroundColor: Colors.red),
      );
      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (senha != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao cadastrar';
      if (e.code == 'email-already-in-use') {
        mensagem = 'E-mail já está em uso';
      } else if (e.code == 'invalid-email') {
        mensagem = 'E-mail inválido';
      } else if (e.code == 'weak-password') {
        mensagem = 'Senha fraca, use ao menos 6 caracteres';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao cadastrar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // vermelho FireApp
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// LOGO
                Image.asset("assets/logo.png", width: 120),

                const SizedBox(height: 40),

                /// NOME COMPLETO
                AppInput(
                  label: "Nome Completo",
                  hint: "Digite seu nome completo",
                  controller: _nome,
                ),

                const SizedBox(height: 18),

                /// EMAIL
                AppInput(
                  label: "E-mail",
                  hint: "Digite seu e-mail",
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                /// DATA DE NASCIMENTO
                AppInput(
                  label: "Data de Nascimento",
                  hint: "Selecione no calendário",
                  controller: _dataNasc,
                  readOnly: true,
                  onTap: _selecionarData,
                ),

                const SizedBox(height: 18),

                /// CPF
                AppInput(
                  label: "CPF",
                  hint: "Digite aqui seu CPF",
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),

                /// SENHA
                AppInput(
                  label: "Senha",
                  hint: "Digite sua senha",
                  controller: _senha,
                  obscure: true,
                ),

                const SizedBox(height: 18),

                /// CONFIRMAR SENHA
                AppInput(
                  label: "Confirme a senha",
                  hint: "Confirme sua senha",
                  controller: _confirmarSenha,
                  obscure: true,
                ),

                const SizedBox(height: 24),

                /// BOTÃO CADASTRAR (PRIMARY)
                AppButton(
                  text: "Cadastrar",
                  onPressed: () => _registrar(),
                  isDisabled: _isLoading,
                ),

                const SizedBox(height: 24),

                /// TEXTO "OU"
                Text(
                  "OU",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 24),

                /// BOTÃO GOOGLE (OUTLINED + ÍCONE)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(
                        0xFFDDDDDD,
                      ), // igual ao Figma
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/google.png", width: 22, height: 22),
                        const SizedBox(width: 12),
                        const Text(
                          "Entrar com o google",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                /// JÁ POSSUI CONTA?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Já possui uma conta ?", style: AppTextStyles.body),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.loginRegister);
                      },
                      child: Text(
                        "Faça o login",
                        style: AppTextStyles.bodyBold.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                /// TERMOS E PRIVACIDADE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        "Ao confirmar, estou de acordo com os",
                        style: AppTextStyles.small,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Termos de Uso e com o\nAviso de Privacidade do FireApp",
                          style: AppTextStyles.small.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _emailValido(String email) {
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    return regex.hasMatch(email);
  }

  String? _validarCpf(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'\D'), '');
    if (numeros.length != 11) return 'CPF deve ter 11 dígitos';
    if (RegExp(r'^(\d)\1{10}$').hasMatch(numeros)) return 'CPF inválido';

    int calcularDigito(String base) {
      var soma = 0;
      for (var i = 0; i < base.length; i++) {
        soma += int.parse(base[i]) * ((base.length + 1) - i);
      }
      final resto = soma % 11;
      return resto < 2 ? 0 : 11 - resto;
    }

    final primeiroDigito = calcularDigito(numeros.substring(0, 9));
    final segundoDigito = calcularDigito(
      numeros.substring(0, 9) + primeiroDigito.toString(),
    );

    if (numeros[9] != primeiroDigito.toString() ||
        numeros[10] != segundoDigito.toString()) {
      return 'CPF inválido';
    }

    return null;
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final dataInicial = _dataSelecionada ?? DateTime(2000);
    final selecionada = await showDatePicker(
      context: context,
      initialDate: dataInicial.isAfter(agora) ? agora : dataInicial,
      firstDate: DateTime(1900),
      lastDate: agora,
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      setState(() {
        _dataSelecionada = selecionada;
        _dataNasc.text = _formatarData(selecionada);
      });
    }
  }
}
