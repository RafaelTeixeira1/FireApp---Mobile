import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../database/user_profile_service.dart';
import '../model/user_profile_model.dart';
import '../core/navigation/app_routes.dart';

/// Tela de perfil do usuário
/// Permite visualizar e editar dados pessoais, preferências e gerenciar logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();

  UserProfileModel? _perfil;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _imagemSelecionada;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers para edição
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _localizacaoController;

  @override
  void initState() {
    super.initState();
    // Inicializar controllers com valores vazios
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _localizacaoController = TextEditingController();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    try {
      final perfil = await _profileService.obterPerfil();
      setState(() {
        _perfil = perfil;
        // Atualizar valores dos controllers já inicializados
        _nomeController.text = _perfil?.nome ?? '';
        _telefoneController.text = _perfil?.telefone ?? '';
        _localizacaoController.text = _perfil?.localizacao ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregear perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_perfil == null) return;
    
    try {
      final perfilAtualizado = _perfil!.copyWith(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        localizacao: _localizacaoController.text.trim(),
      );

      await _profileService.atualizarPerfil(perfilAtualizado);

      setState(() {
        _perfil = perfilAtualizado;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _atualizarNotificacoes(bool valor) async {
    try {
      await _profileService.atualizarPreferenciaNotificacoes(valor);
      if (_perfil != null) {
        setState(() {
          _perfil = _perfil?.copyWith(receberNotificacoes: valor);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _atualizarAlertas(bool valor) async {
    try {
      await _profileService.atualizarPreferenciaAlertas(valor);
      if (_perfil != null) {
        setState(() {
          _perfil = _perfil?.copyWith(receberAlertas: valor);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (imagem != null) {
        setState(() {
          _imagemSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _capturarFoto() async {
    try {
      final XFile? imagem = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (imagem != null) {
        setState(() {
          _imagemSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _obterLocalizacaoAutomatica() async {
    try {
      // Verificar se a localização está habilitada
      bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço de localização desabilitado'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Verificar permissões
      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada permanentemente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Obter posição
      Position posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      if (!mounted) return;
      setState(() {
        _localizacaoController.text =
            '${posicao.latitude.toStringAsFixed(4)}, ${posicao.longitude.toStringAsFixed(4)}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização obtida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _realizarLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _profileService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.telaInicial,
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao fazer logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarDeletarConta() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Conta'),
        content: const Text(
          'Tem certeza que deseja deletar sua conta? Esta ação é irreversível e você perderá todos os seus dados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Segunda confirmação
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Deletar Conta - Confirmação Final'),
                  content: const Text(
                    'Esta é sua última chance. Você realmente deseja deletar sua conta?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await _profileService.deletarConta();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.telaInicial,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao deletar conta: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Deletar Permanentemente',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar e Informações Básicas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  // Avatar placeholder (seria a foto do usuário)
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: _imagemSelecionada != null
                            ? ClipOval(
                                child: Image.file(
                                  _imagemSelecionada!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: PopupMenuButton<int>(
                              onSelected: (value) {
                                if (value == 0) {
                                  _selecionarImagem();
                                } else if (value == 1) {
                                  _capturarFoto();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(Icons.image),
                                      SizedBox(width: 8),
                                      Text('Galeria'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.camera_alt),
                                      SizedBox(width: 8),
                                      Text('Câmera'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _perfil?.nome ?? 'Usuário',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _perfil?.email ?? 'Email não disponível',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Dados Pessoais - Modo Edição
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados Pessoais',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 16),

                    // Nome
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Digite seu nome',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Telefone
                    TextField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: 'Digite seu telefone',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Localização
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _localizacaoController,
                            decoration: InputDecoration(
                              labelText: 'Localização',
                              hintText: 'Digite sua localização',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: _obterLocalizacaoAutomatica,
                            tooltip: 'Obter localização automática',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botões de Ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => _isEditing = false),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _salvarAlteracoes,
                            icon: const Icon(Icons.check),
                            label: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              // Dados Pessoais - Modo Visualização
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Pessoais',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'Nome',
                      value: _perfil?.nome ?? 'Não preenchido',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Telefone',
                      value: _perfil?.telefone ?? 'Não preenchido',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Localização',
                      value: _perfil?.localizacao ?? 'Não preenchido',
                    ),
                  ],
                ),
              ),

            const Divider(),

            // Preferências
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferências',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Receber Notificações'),
                    subtitle: const Text('Alertas gerais do aplicativo'),
                    value: _perfil?.receberNotificacoes ?? true,
                    onChanged: _atualizarNotificacoes,
                    activeThumbColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Receber Alertas'),
                    subtitle: const Text('Alertas de incêndios próximos'),
                    value: _perfil?.receberAlertas ?? true,
                    onChanged: _atualizarAlertas,
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const Divider(),

            // Ações
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _realizarLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da Conta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmarDeletarConta,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Deletar Conta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
