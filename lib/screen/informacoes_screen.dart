import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class InformacoesScreen extends StatelessWidget {
  const InformacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔥 LOGO
            Image.asset('assets/logo.png', width: 90, height: 90),

            const SizedBox(height: 10),

            /// TÍTULO
            Text(
              "Informações",
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontSize: 26,
              ),
            ),

            const SizedBox(height: 30),

            /// SUBTÍTULO
            Text(
              "Dicas de Prevenção",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 30),

            /// GRID – 6 CARDS
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.95,
              children: const [
                _InfoCard(
                  icon: Icons.local_fire_department_outlined,
                  title: "Evite Queimadas",
                  description:
                      "Nunca queime lixo ou vegetação seca em áreas florestais.",
                ),
                _InfoCard(
                  icon: Icons.cleaning_services_outlined,
                  title: "Limpeza de Área",
                  description:
                      "Mantenha a vegetação aparada ao redor das construções.",
                ),
                _InfoCard(
                  icon: Icons.smoke_free_outlined,
                  title: "Não Jogue Bitucas no Chão",
                  description:
                      "Descarte cigarros em recipientes apropriados e apagados.",
                ),
                _InfoCard(
                  icon: Icons.delete_outline,
                  title: "Lixo no Lixo",
                  description: "Vidro e plástico na mata podem causar fogo.",
                ),
                _InfoCard(
                  icon: Icons.warning_amber_outlined,
                  title: "Denuncie Focos",
                  description:
                      "Avise autoridades ao perceber fumaça ou fogo fora de controle.",
                ),
                _InfoCard(
                  icon: Icons.phone_in_talk_outlined,
                  title: "Contatos de Emergência",
                  description:
                      "Mantenha uma lista de contatos de emergência atualizada.",
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// CARD SIMPLES – ITEM DO GRID
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black, size: 32),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
