import 'package:flutter/material.dart';
import 'package:fire_app/components/app_button.dart';
import 'package:fire_app/theme/app_colors.dart';
import 'package:fire_app/theme/app_text_styles.dart';

class AjudaComentariosScreen extends StatefulWidget {
  const AjudaComentariosScreen({super.key});

  @override
  State<AjudaComentariosScreen> createState() => _AjudaComentariosScreenState();
}

class _AjudaComentariosScreenState extends State<AjudaComentariosScreen> {
  final TextEditingController feedbackController = TextEditingController();

  final List<Map<String, String>> faq = [
    {
      "pergunta": "Como reportar um incêndio?",
      "resposta":
          "No menu principal, toque em 'Reportar Incêndio Agora' e siga as instruções.",
    },
    {
      "pergunta": "Como funciona a área desenhada no mapa?",
      "resposta":
          "Você pode desenhar um polígono para marcar a área exata atingida pelo incêndio.",
    },
    {
      "pergunta": "Posso visualizar alertas próximos?",
      "resposta":
          "Sim, na tela 'Meus Alertas' você vê notificações da sua região.",
    },
  ];

  List<bool> isExpanded = [];

  @override
  void initState() {
    super.initState();
    isExpanded = List<bool>.filled(faq.length, false);
  }

  void enviarFeedback() {
    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite seu comentário antes de enviar.")),
      );
      return;
    }

    feedbackController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Obrigado pelo seu feedback!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // 🔥 Fundo vermelho
      appBar: AppBar(
        title: const Text("Ajuda e Comentários"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fale Conosco",
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // 🔥 CAMPO DE TEXTO VISÍVEL (com borda)
            Text(
              "Mensagem",
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white10, // leve branco transparente
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white70, // 🔥 borda visível
                  width: 1.3,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: feedbackController,
                maxLines: 6,
                style: AppTextStyles.body.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Digite aqui sua dúvida, sugestão ou problema...",
                  hintStyle: AppTextStyles.labelHint.copyWith(
                    color: Colors.white70,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 22),

            AppButton(text: "Enviar", onPressed: enviarFeedback),

            const SizedBox(height: 35),

            Text(
              "Perguntas Frequentes",
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              itemCount: faq.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  color: Colors.white, // card claro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq[index]["pergunta"]!,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.darkText,
                      ),
                    ),
                    onExpansionChanged: (val) {
                      setState(() => isExpanded[index] = val);
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          faq[index]["resposta"]!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
