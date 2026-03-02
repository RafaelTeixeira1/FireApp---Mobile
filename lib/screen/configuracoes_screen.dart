import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/theme_provider.dart';
import '../theme/app_colors.dart';

/// Tela de Configurações do aplicativo
/// Permite ao usuário gerenciar preferências como tema
class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 16),

              // Seção de Aparência
              _buildSectionHeader('Aparência', isDark),

              // Toggle de Dark Mode
              SwitchListTile(
                title: const Text(
                  'Tema Escuro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isDark ? 'Ativado' : 'Desativado',
                ),
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                ),
              ),

              const Divider(),

              // Informações do App
              _buildSectionHeader('Sobre', isDark),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versão do App'),
                subtitle: const Text('1.0.0'),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('FireApp Mobile'),
                subtitle: const Text('Sistema de Monitoramento de Incêndios'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkGreyText : AppColors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
