import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../database/incendio_service.dart';
import '../model/incendio_model.dart';

class MeusAlertasScreen extends StatelessWidget {
  MeusAlertasScreen({super.key});

  final IncendioService _incendioService = IncendioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BOTÃO VOLTAR
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 25),

              /// TÍTULO
              Text("Meus Alertas", style: AppTextStyles.titleMedium),

              const SizedBox(height: 20),

              /// LISTA DE ALERTAS COM STREAM
              Expanded(
                child: StreamBuilder<List<IncendioModel>>(
                  stream: _incendioService.streamMeusIncendios(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erro ao carregar alertas",
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    final incendios = snapshot.data ?? [];

                    if (incendios.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 64,
                              color: Colors.white30,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Nenhum alerta registrado",
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: incendios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final incendio = incendios[index];
                        return _AlertaCard(
                          incendio: incendio,
                          onTap: () {
                            _mostrarDetalhes(context, incendio);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context, IncendioModel incendio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detalhes do Alerta"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalhe("Descrição", incendio.descricao),
              _buildDetalhe("Nível de Risco", incendio.nivelRisco),
              _buildDetalhe(
                "Data",
                incendio.criadoEm.isNotEmpty
                    ? DateTime.parse(incendio.criadoEm).toString().split('.')[0]
                    : "N/A",
              ),
              if (incendio.latitude != null && incendio.longitude != null)
                _buildDetalhe(
                  "Localização",
                  "Lat: ${incendio.latitude?.toStringAsFixed(4)}, Lng: ${incendio.longitude?.toStringAsFixed(4)}",
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhe(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final IncendioModel incendio;
  final VoidCallback onTap;

  const _AlertaCard({required this.incendio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// ÍCONE DE ALERTA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.red,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            /// TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incendio.descricao.length > 30
                        ? "${incendio.descricao.substring(0, 30)}..."
                        : incendio.descricao,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateTime.parse(
                      incendio.criadoEm,
                    ).toString().split('.').first,
                    style: AppTextStyles.small.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getCorRisco(
                        incendio.nivelRisco,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Risco: ${incendio.nivelRisco}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getCorRisco(incendio.nivelRisco),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.black45, size: 28),
          ],
        ),
      ),
    );
  }

  Color _getCorRisco(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'alto':
        return Colors.red;
      case 'médio':
      case 'medio':
        return Colors.orange;
      case 'baixo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
