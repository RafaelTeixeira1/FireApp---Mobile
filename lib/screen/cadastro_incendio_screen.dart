import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_button.dart';
import '../components/app_input.dart';
import '../database/incendio_service.dart';
import '../model/incendio_model.dart';
import '../core/notifications/notification_service.dart';
import 'adicionar_mapa_screen.dart';

class CadastroIncendioScreen extends StatefulWidget {
  const CadastroIncendioScreen({super.key});

  @override
  State<CadastroIncendioScreen> createState() => _CadastroIncendioScreenState();
}

class _CadastroIncendioScreenState extends State<CadastroIncendioScreen> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController distanciaController = TextEditingController();

  final Location _location = Location();
  final IncendioService _incendioService = IncendioService();
  final ImagePicker _imagePicker = ImagePicker();

  LatLng? _currentLocation;
  double? _direcaoBussola; // Em graus (0-360)
  File? _fotoSelecionada;

  bool isLoading = true;
  bool isSaving = false;
  bool _capturandoDirecao = false;

  // Polígono desenhado no mapa de seleção
  List<LatLng> areaPoligono = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((loc) {
      if (loc.latitude != null && loc.longitude != null) {
        setState(() {
          _currentLocation = LatLng(loc.latitude!, loc.longitude!);
          isLoading = false;
        });
      }
    });
  }

  // Capturar foto
  Future<void> _capturarFoto() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (foto != null) {
        setState(() {
          _fotoSelecionada = File(foto.path);
        });
      }
    } catch (e) {
      debugPrint('❌ Erro ao capturar foto: $e');
    }
  }

  // Capturar direção da bússola
  void _capturarDirecao() {
    setState(() {
      _capturandoDirecao = true;
    });

    // Ouvir bússola por 3 segundos e pegar última leitura
    Stream<CompassEvent>? compassStream = FlutterCompass.events;

    if (compassStream == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Bússola não disponível neste dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _capturandoDirecao = false;
      });
      return;
    }

    compassStream
        .take(15)
        .listen((event) {
          setState(() {
            _direcaoBussola = event.heading;
          });
        })
        .onDone(() {
          setState(() {
            _capturandoDirecao = false;
          });
          if (!mounted) return;
          if (_direcaoBussola != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ Direção capturada: ${_direcaoBussola!.toStringAsFixed(0)}°',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
  }

  // Calcular coordenadas do incêndio baseado em posição atual + direção + distância
  LatLng? _calcularCoordenadas() {
    if (_currentLocation == null ||
        _direcaoBussola == null ||
        distanciaController.text.isEmpty) {
      return null;
    }

    final distanciaMetros = double.tryParse(distanciaController.text);
    if (distanciaMetros == null || distanciaMetros <= 0) return null;

    // Converter para radianos
    final lat1 = _currentLocation!.latitude * math.pi / 180;
    final lng1 = _currentLocation!.longitude * math.pi / 180;
    final bearing = _direcaoBussola! * math.pi / 180;
    final distanciaKm = distanciaMetros / 1000;
    const raioTerra = 6371; // km

    // Fórmula haversine para calcular novo ponto
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(distanciaKm / raioTerra) +
          math.cos(lat1) *
              math.sin(distanciaKm / raioTerra) *
              math.cos(bearing),
    );

    final lng2 =
        lng1 +
        math.atan2(
          math.sin(bearing) *
              math.sin(distanciaKm / raioTerra) *
              math.cos(lat1),
          math.cos(distanciaKm / raioTerra) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(lat2 * 180 / math.pi, lng2 * 180 / math.pi);
  }

  // Converter foto para Base64 para salvar no Realtime Database
  Future<String?> _converterFotoBase64() async {
    if (_fotoSelecionada == null) return null;

    try {
      debugPrint('⏳ Convertendo foto para Base64...');
      debugPrint('📁 Arquivo: ${_fotoSelecionada!.path}');

      final bytes = await _fotoSelecionada!.readAsBytes();
      final tamanhoOriginal = bytes.length;
      debugPrint(
        '📊 Tamanho original: ${(tamanhoOriginal / 1024).toStringAsFixed(2)} KB',
      );

      // Limitar tamanho para não sobrecarregar o RTDB (max ~100KB recomendado)
      if (tamanhoOriginal > 150 * 1024) {
        debugPrint(
          '⚠️ Foto muito grande (${(tamanhoOriginal / 1024).toStringAsFixed(2)} KB), comprimindo...',
        );
        // Aqui você pode adicionar compressão se necessário
        // Por ora, vamos aceitar e avisar
      }

      final base64String = base64Encode(bytes);
      debugPrint(
        '✅ Foto convertida para Base64: ${(base64String.length / 1024).toStringAsFixed(2)} KB',
      );

      return base64String;
    } catch (e) {
      debugPrint('❌ Erro ao converter foto: $e');
      return null;
    }
  }

  // Abre a tela para desenhar área
  Future<void> _abrirMapaDesenho() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarMapaScreen()),
    );

    if (!mounted) return;

    if (resultado != null && resultado is List<LatLng>) {
      setState(() {
        areaPoligono = resultado;
      });
    }
  }

  // Salvar incêndio no banco
  void _salvarIncendio() async {
    if (descricaoController.text.isEmpty ||
        areaPoligono.isEmpty ||
        _direcaoBussola == null ||
        distanciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Preencha todos os campos, capture a direção e desenhe a área.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Verificar autenticação
      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
        '👤 [CadastroIncendio] Verificando autenticação - Usuário: ${user?.uid ?? "NÃO AUTENTICADO"}',
      );

      if (user == null) {
        throw Exception('❌ Você não está autenticado. Faça login primeiro.');
      }

      // Converter foto para Base64 (se houver)
      debugPrint('📸 [CadastroIncendio] Iniciando conversão de foto...');
      String? fotoBase64;
      if (_fotoSelecionada != null) {
        debugPrint('⏳ Foto selecionada, convertendo...');
        try {
          fotoBase64 = await _converterFotoBase64();
          if (fotoBase64 == null) {
            debugPrint(
              '⚠️ AVISO: Foto não foi convertida, continuando sem foto',
            );
          }
        } catch (e) {
          debugPrint('⚠️ ERRO na conversão de foto, salvando sem foto: $e');
          fotoBase64 = null;
        }
      } else {
        debugPrint('⏭️ Sem foto selecionada');
      }

      // Calcular coordenadas do incêndio
      debugPrint('📍 [CadastroIncendio] Calculando coordenadas...');
      final coordenadasIncendio = _calcularCoordenadas();

      if (coordenadasIncendio == null) {
        throw Exception('Erro ao calcular coordenadas do incêndio');
      }

      debugPrint(
        '✅ [CadastroIncendio] Coordenadas calculadas: $coordenadasIncendio',
      );
      debugPrint('🔥 [CadastroIncendio] Iniciando salvamento do incêndio...');
      debugPrint('📍 Localização usuário: $_currentLocation');
      debugPrint('📍 Localização incêndio: $coordenadasIncendio');
      debugPrint('🧭 Direção: $_direcaoBussola°');
      debugPrint('📏 Distância: ${distanciaController.text}m');
      debugPrint('🗺️ Polígono com ${areaPoligono.length} pontos');
      debugPrint(
        '📸 Foto Base64: ${fotoBase64 != null ? "✅ Convertida (${(fotoBase64.length / 1024).toStringAsFixed(2)} KB)" : "❌ Sem foto"}',
      );
      debugPrint('👤 Usuário ID: ${user.uid}');

      debugPrint('🔨 [CadastroIncendio] Criando modelo do incêndio...');
      final incendio = IncendioModel(
        descricao: descricaoController.text,
        nivelRisco: 'Médio', // Será calculado automaticamente no futuro
        areaPoligono: areaPoligono,
        criadoEm: DateTime.now().toIso8601String(),
        latitude: coordenadasIncendio.latitude,
        longitude: coordenadasIncendio.longitude,
        fotoUrl: fotoBase64, // Agora é Base64 ao invés de URL
        direcao: _direcaoBussola,
        distanciaMetros: double.parse(distanciaController.text),
      );

      debugPrint(
        '📝 [CadastroIncendio] Incêndio criado: ${incendio.descricao}',
      );
      debugPrint(
        '📝 [CadastroIncendio] Campo fotoUrl: ${incendio.fotoUrl != null ? "PREENCHIDO (${(incendio.fotoUrl!.length / 1024).toStringAsFixed(2)} KB)" : "NULL"}',
      );

      debugPrint('💾 [CadastroIncendio] Salvando no banco de dados...');
      final id = await _incendioService.salvarIncendio(incendio);

      debugPrint('✅ [CadastroIncendio] Incêndio salvo com ID: $id');
      debugPrint(
        '✅ [CadastroIncendio] Foto Base64 salva no banco: ${incendio.fotoUrl != null ? "SIM" : "NÃO"}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✓ Incêndio registrado com sucesso!\nAtualizando mapa...",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // 🔔 Disparar notificação imediata de proximidade
      if (_currentLocation != null) {
        final distanciaKm = math.sqrt(
          math.pow(_currentLocation!.latitude - coordenadasIncendio.latitude, 2) +
          math.pow(_currentLocation!.longitude - coordenadasIncendio.longitude, 2)
        ) * 111; // Aproximação: 1 grau ≈ 111km
        
        if (distanciaKm <= 5) {
          debugPrint('🔔 [CadastroIncendio] Incêndio está a ${distanciaKm.toStringAsFixed(1)} km - Enviando notificação imediata');
          NotificationService.showNearbyIncendio(
            id: id,
            titulo: '🔥 Incêndio Registrado Perto de Você!',
            corpo: '${descricaoController.text} • ${distanciaKm.toStringAsFixed(1)} km de distância',
          );
        }
      }

      // Aguardar um pouco para sincronizar
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Limpar formulário
      descricaoController.clear();
      distanciaController.clear();
      setState(() {
        areaPoligono = [];
        _fotoSelecionada = null;
        _direcaoBussola = null;
      });

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      debugPrint('❌ [CadastroIncendio] Erro ao salvar: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erro ao salvar: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordenadasCalculadas = _calcularCoordenadas();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔙 topo
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Registrar incêndio",
                style: AppTextStyles.titleMedium,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// 📝 Descrição
                      AppInput(
                        label: "Descrição do incêndio",
                        hint: "Ex: Fumaça densa próxima à mata",
                        controller: descricaoController,
                      ),
                      const SizedBox(height: 16),

                      /// 📸 Foto
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: _fotoSelecionada == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nenhuma foto capturada',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _fotoSelecionada!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: _fotoSelecionada == null
                            ? "📸 Capturar Foto"
                            : "📸 Trocar Foto",
                        outlined: true,
                        onPressed: _capturarFoto,
                      ),
                      const SizedBox(height: 20),

                      /// 🧭 Direção da Bússola
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🧭 Direção:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _direcaoBussola == null
                                      ? 'Não capturada'
                                      : '${_direcaoBussola!.toStringAsFixed(0)}°',
                                  style: TextStyle(
                                    color: _direcaoBussola == null
                                        ? Colors.orange
                                        : Colors.greenAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aponte o celular na direção do incêndio',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: _capturandoDirecao
                            ? "⏳ Capturando..."
                            : "🧭 Capturar Direção",
                        outlined: true,
                        onPressed: _capturandoDirecao
                            ? () {}
                            : _capturarDirecao,
                      ),
                      const SizedBox(height: 20),

                      /// 📏 Distância
                      AppInput(
                        label: "Distância aproximada (metros)",
                        hint: "Ex: 500",
                        controller: distanciaController,
                        keyboardType: TextInputType.number,
                      ),

                      if (coordenadasCalculadas != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📍 Coordenadas calculadas do incêndio:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${coordenadasCalculadas.latitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Lng: ${coordenadasCalculadas.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      /// 🗺️ Botão desenhar área
                      AppButton(
                        text: areaPoligono.isEmpty
                            ? "🗺️ Desenhar área no mapa"
                            : "🗺️ Área desenhada (${areaPoligono.length} pontos)",
                        outlined: true,
                        onPressed: _abrirMapaDesenho,
                      ),

                      const SizedBox(height: 20),

                      /// 🔴 Salvar
                      AppButton(
                        text: isSaving ? "⏳ Salvando..." : "✓ Salvar incêndio",
                        onPressed:
                            (descricaoController.text.isNotEmpty &&
                                areaPoligono.isNotEmpty &&
                                _direcaoBussola != null &&
                                distanciaController.text.isNotEmpty &&
                                !isSaving)
                            ? _salvarIncendio
                            : () {},
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
