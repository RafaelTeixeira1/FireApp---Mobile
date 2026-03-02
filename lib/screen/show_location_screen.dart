import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:fire_app/model/shared_location_model.dart';
import 'package:fire_app/model/incendio_model.dart';
import 'package:fire_app/database/firebase_location_service.dart';
import 'package:fire_app/database/incendio_service.dart';

class ShowLocationScreen extends StatefulWidget {
  const ShowLocationScreen({super.key});

  @override
  State<ShowLocationScreen> createState() => _ShowLocationScreenState();
}

class _ShowLocationScreenState extends State<ShowLocationScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseLocationService _firebaseLocationService =
      FirebaseLocationService();
  final IncendioService _incendioService = IncendioService();

  bool isLoading = true;
  bool isLoadingSharedLocations = false;

  LatLng? _currentLocation;
  LatLng? _destination;

  List<LatLng> _route = [];
  List<SharedLocation> _sharedLocations = [];
  List<IncendioModel> _incendios = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSharedLocations();
    _loadIncendios();
  }

  void _loadSharedLocations() {
    setState(() {
      isLoadingSharedLocations = true;
    });

    _firebaseLocationService.getSharedLocations().listen(
      (locations) {
        setState(() {
          _sharedLocations = locations;
          isLoadingSharedLocations = false;
        });
      },
      onError: (error) {
        debugPrint("Erro ao carregar locais: $error");
        setState(() {
          isLoadingSharedLocations = false;
        });
      },
    );
  }

  void _loadIncendios() {
    debugPrint('🗺️ [ShowLocationScreen] Iniciando stream de incêndios...');
    _incendioService.streamIncendios().listen(
      (incendios) {
        debugPrint(
          '🔥 [ShowLocationScreen] Recebido ${incendios.length} incêndios',
        );
        for (final inc in incendios) {
          debugPrint(
            '  - ${inc.descricao}: ${inc.areaPoligono.length} pontos, Lat=${inc.latitude}, Lng=${inc.longitude}',
          );
        }
        setState(() {
          _incendios = incendios;
        });
      },
      onError: (error) {
        debugPrint("❌ [ShowLocationScreen] Erro ao carregar incêndios: $error");
      },
    );
  }

  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;

    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchCoordinatesPoints(String location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1',
      );
      final headers = {'User-Agent': 'FireApp/1.0 (fireapp62@gmail.com)'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty && data is List) {
          final lat = double.tryParse(data[0]['lat']?.toString() ?? '');
          final lon = double.tryParse(data[0]['lon']?.toString() ?? '');

          if (lat != null && lon != null) {
            setState(() {
              _destination = LatLng(lat, lon);
            });
            await fetchRoute();
          } else {
            errorMessage('Coordenadas inválidas na resposta');
          }
        } else {
          errorMessage(
            'Localização não encontrada, por favor tente outra pesquisa',
          );
        }
      } else {
        // Tratamento para outros status codes
        final errorMsg = _handleErrorResponse(response);
        errorMessage('Erro na requisição: $errorMsg');
      }
    } catch (e) {
      errorMessage('Erro inesperado: $e');
    }
  }

  String _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return 'Requisição inválida';
      case 404:
        return 'Serviço não encontrado';
      case 429:
        return 'Muitas requisições - tente novamente mais tarde';
      case 500:
        return 'Erro interno do servidor';
      default:
        return 'Erro HTTP ${response.statusCode}';
    }
  }

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
      '${_currentLocation!.longitude},${_currentLocation!.latitude};'
      '${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyLine(geometry);
    } else {
      errorMessage('Falha em encontrar as rotas, tente novamente mais tarde');
    }
  }

  void _decodePolyLine(String encodedPolyLine) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePoints = polylinePoints.decodePolyline(
      encodedPolyLine,
    );

    setState(() {
      _route = decodePoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Localização Atual não disponível.")),
      );
    }
  }

  Marker _buildSharedLocationMarker(SharedLocation location) {
    Color markerColor;
    IconData markerIcon;

    switch (location.type) {
      case 'park':
        markerColor = Colors.green;
        markerIcon = Icons.park;
        break;
      case 'landmark':
        markerColor = Colors.orange;
        markerIcon = Icons.landscape;
        break;
      case 'restaurant':
        markerColor = Colors.red;
        markerIcon = Icons.restaurant;
        break;
      case 'fire':
        markerColor = Colors.red;
        markerIcon = Icons.fireplace;
        break;
      default:
        markerColor = Colors.blue;
        markerIcon = Icons.location_pin;
    }

    return Marker(
      point: location.toLatLng(),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          _showLocationDetails(location);
        },
        child: SizedBox(
          width: 50,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(markerIcon, color: markerColor, size: 25),
              const SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  location.description, //O que mostra abaixo do ponto
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDetails(SharedLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(location.description),
            SizedBox(height: 8),
            Text(
              'Coordenadas: ${location.lat.toStringAsFixed(4)}, ${location.lng.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setDestinationFromSharedLocation(location);
            },
            child: Text('Traçar Rota'),
          ),
        ],
      ),
    );
  }

  void _setDestinationFromSharedLocation(SharedLocation location) {
    setState(() {
      _destination = location.toLatLng();
    });
    fetchRoute();
  }

  // 🔥 Criar marcador de incêndio
  Marker _buildIncendioMarker(IncendioModel incendio) {
    if (incendio.latitude == null || incendio.longitude == null) {
      return Marker(point: LatLng(0, 0), child: SizedBox.shrink());
    }

    Color corRisco = _getCorPorRisco(incendio.nivelRisco);

    return Marker(
      point: LatLng(incendio.latitude!, incendio.longitude!),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _mostrarDetalhesIncendio(incendio),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, color: corRisco, size: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                incendio.nivelRisco,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: corRisco,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Obter cor baseado no risco
  Color _getCorPorRisco(String nivelRisco) {
    switch (nivelRisco.toLowerCase()) {
      case 'alto':
        return Colors.red;
      case 'médio':
      case 'medio':
        return Colors.orange;
      case 'baixo':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // 📋 Mostrar detalhes do incêndio
  void _mostrarDetalhesIncendio(IncendioModel incendio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: _getCorPorRisco(incendio.nivelRisco),
            ),
            SizedBox(width: 8),
            Expanded(child: Text('Incêndio Registrado')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalheItem('Descrição', incendio.descricao),
              SizedBox(height: 12),
              _buildDetalheItem('Nível de Risco', incendio.nivelRisco),
              SizedBox(height: 12),
              _buildDetalheItem('Data', _formatarData(incendio.criadoEm)),
              if (incendio.latitude != null && incendio.longitude != null) ...[
                SizedBox(height: 12),
                _buildDetalheItem(
                  'Coordenadas',
                  'Lat: ${incendio.latitude!.toStringAsFixed(4)}, Lng: ${incendio.longitude!.toStringAsFixed(4)}',
                ),
              ],
              if (incendio.areaPoligono.isNotEmpty) ...[
                SizedBox(height: 12),
                _buildDetalheItem(
                  'Área Mapeada',
                  '${incendio.areaPoligono.length} pontos no polígono',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          if (incendio.latitude != null && incendio.longitude != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _destination = LatLng(
                    incendio.latitude!,
                    incendio.longitude!,
                  );
                });
                fetchRoute();
              },
              child: Text('Traçar Rota'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetalheItem(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(valor, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  String _formatarData(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  //FIM MARCADORES

  void _addCurrentLocation() {
    if (_currentLocation != null) {
      final newLocation = SharedLocation(
        id: '',
        lat: _currentLocation!.latitude,
        lng: _currentLocation!.longitude,
        name: 'Novo Ponto',
        description: '${DateTime.now()}',
        createdBy: 'current_user', // Você pode pegar do Firebase Auth
        type: 'point',
      );

      _firebaseLocationService.addSharedLocation(newLocation);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ponto adicionado!')));
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _title() {
    return const Text('Marque pontos de Incêndio!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _title(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red, Colors.yellow],
              stops: [0.0, 0.5, 9.0],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentLocation ??
                        const LatLng(0, 0), //LatLng(-15.351792,-49.595488),
                    initialZoom: 12,
                    minZoom: 0,
                    maxZoom: 100,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.fireapp.app",
                    ),

                    // 🔥 Polígonos dos incêndios
                    PolygonLayer(
                      polygons: _incendios
                          .where((incendio) => incendio.areaPoligono.isNotEmpty)
                          .map((incendio) {
                            final cor = _getCorPorRisco(incendio.nivelRisco);
                            return Polygon(
                              points: incendio.areaPoligono,
                              color: cor.withValues(alpha: 0.3),
                              borderColor: cor,
                              borderStrokeWidth: 2,
                            );
                          })
                          .toList(),
                    ),

                    CurrentLocationLayer(
                      style: LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          child: Icon(Icons.location_pin, color: Colors.red),
                        ),
                        markerSize: Size(35, 35),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),

                    // Marcadores de localizações compartilhadas
                    MarkerLayer(
                      markers: _sharedLocations
                          .map(_buildSharedLocationMarker)
                          .toList(),
                    ),

                    // 🔥 Marcadores de incêndios
                    MarkerLayer(
                      markers: _incendios
                          .where(
                            (incendio) =>
                                incendio.latitude != null &&
                                incendio.longitude != null,
                          )
                          .map(_buildIncendioMarker)
                          .toList(),
                    ),

                    if (_destination != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destination!,
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    if (_currentLocation != null &&
                        _destination != null &&
                        _route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            strokeWidth: 5,
                            color: Colors.red,
                          ),
                        ],
                      ),
                  ],
                ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Digite a localização',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      final location = _locationController.text.trim();
                      if (location.isNotEmpty) {
                        _fetchCoordinatesPoints(location);
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_sharedLocations.length} pontos encontrados',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão para adicionar ponto atual (opcional)
          FloatingActionButton.small(
            heroTag: "add_location_button",
            onPressed: _addCurrentLocation,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add_location, color: Colors.white),
          ),
          SizedBox(height: 8),
          // Botão de localização atual
          FloatingActionButton(
            heroTag: "my_location_button",
            onPressed: _userCurrentLocation,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
