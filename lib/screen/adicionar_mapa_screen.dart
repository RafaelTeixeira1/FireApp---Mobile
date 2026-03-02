import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_button.dart';

import 'package:location/location.dart';
import 'package:fire_app/database/firebase_location_service.dart';
import 'package:fire_app/model/shared_location_model.dart';

class AdicionarMapaScreen extends StatefulWidget {
  const AdicionarMapaScreen({super.key});

  @override
  State<AdicionarMapaScreen> createState() => _AdicionarMapaScreenState();
}

class _AdicionarMapaScreenState extends State<AdicionarMapaScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final FirebaseLocationService _firebaseLocationService =
      FirebaseLocationService();

  LatLng? _currentLocation;

  bool isLoading = true;
  bool isDrawing = false;

  final List<LatLng> polygonPoints = [];
  List<SharedLocation> _sharedLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSharedLocations();
  }

  // 🔵 Carregar pontos do Firestore
  void _loadSharedLocations() {
    _firebaseLocationService.getSharedLocations().listen((locations) {
      setState(() {
        _sharedLocations = locations;
      });
    });
  }

  // 📍 Inicializar localização atual
  Future<void> _initializeLocation() async {
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

    _location.onLocationChanged.listen((data) {
      if (data.latitude != null && data.longitude != null) {
        setState(() {
          _currentLocation = LatLng(data.latitude!, data.longitude!);
          isLoading = false;
        });
      }
    });
  }

  // 🎨 Ativar/Desativar modo desenho
  void _toggleDrawing() {
    setState(() {
      isDrawing = !isDrawing;

      if (isDrawing) {
        polygonPoints.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modo desenho ativado! Toque no mapa.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modo desenho desativado.")),
        );
      }
    });
  }

  // ➕ Add ponto ao polígono
  void _onMapTap(LatLng point) {
    if (!isDrawing) return;
    setState(() => polygonPoints.add(point));
  }

  // 💾 Salvar área
  void _saveArea() {
    if (polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marque ao menos 3 pontos.")),
      );
      return;
    }

    Navigator.pop(context, polygonPoints);
  }

  // 🔥 Criar marcadores do Firestore (iguais ao mapa principal)
  Marker _buildSharedMarker(SharedLocation location) {
    return Marker(
      point: location.toLatLng(),
      width: 50,
      height: 50,
      child: Icon(Icons.location_on, color: Colors.red, size: 35),
    );
  }

  @override
  Widget build(BuildContext context) {
    final polygonLayer = PolygonLayer(
      polygons: [
        if (polygonPoints.isNotEmpty)
          Polygon(
            points: polygonPoints,
            borderColor: Colors.red,
            borderStrokeWidth: 3,
            color: Colors.red.withValues(alpha: 0.3),
          ),
      ],
    );

    final markerLayer = MarkerLayer(
      markers: _sharedLocations.map(_buildSharedMarker).toList(),
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Botão voltar
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔥 Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Adicionar no mapa",
                style: AppTextStyles.titleMedium,
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                isDrawing
                    ? "Toque no mapa para adicionar pontos."
                    : "Ative o modo desenho para marcar a área.",
                style: AppTextStyles.small,
              ),
            ),

            const SizedBox(height: 10),

            // 🗺️ MAPA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isLoading || _currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation!,
                            initialZoom: 12,
                            onTap: (_, point) => _onMapTap(point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: "com.fireapp.app",
                            ),

                            // 🔵 marcador de localização atual
                            CurrentLocationLayer(),

                            // 🔥 marcadores Firestore
                            markerLayer,

                            // 🔺 polígono desenhado
                            polygonLayer,
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🟦 Botão de desenho
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: isDrawing ? "Parar desenho" : "Desenhar área",
                outlined: true,
                onPressed: _toggleDrawing,
              ),
            ),

            const SizedBox(height: 12),

            // 🔴 Botão salvar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: "Salvar área",
                onPressed: _saveArea,
                isDisabled: polygonPoints.length < 3,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
