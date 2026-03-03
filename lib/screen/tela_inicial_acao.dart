import 'package:flutter/material.dart';
import '../auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class TelaInicialAcao extends StatelessWidget {
  const TelaInicialAcao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color ?? Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 40),
                Text('Menu Rápido', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Text('Escolha uma opção para começar', style: AppTextStyles.body),
                const SizedBox(height: 40),
                _MenuCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Reportar incêndio',
                  subtitle: 'Registre um foco de incêndio no mapa.',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.cadastroIncendio),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Meus alertas',
                  subtitle: 'Acompanhe os alertas enviados.',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.meusAlertas),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.map_outlined,
                  title: 'Mapa',
                  subtitle: 'Veja a sua localização atual.',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.showLocation),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Ajuda e comentários',
                  subtitle: 'Tire dúvidas e envie sugestões.',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.ajudaComentarios),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  subtitle: 'Altere preferências, como tema escuro.',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.configuracoes),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.logout,
                  title: 'Sair',
                  subtitle: 'Trocar de conta ou voltar ao login.',
                  onTap: () async {
                    try {
                      await Auth().signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.loginRegister,
                        (route) => false,
                      );
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nao foi possivel sair agora.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.lightText
                          : AppColors.darkText,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkGreyText
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkGreyText
                  : Colors.black45,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
