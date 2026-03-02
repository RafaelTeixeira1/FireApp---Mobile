import 'package:latlong2/latlong.dart';

class IncendioModel {
  final String? id;
  final String descricao;
  final String nivelRisco;
  final List<LatLng> areaPoligono;
  final String criadoEm;
  final String? criadoPor;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;
  final double? direcao; // Direção da bússola em graus
  final double? distanciaMetros; // Distância do incêndio em metros

  IncendioModel({
    this.id,
    required this.descricao,
    required this.nivelRisco,
    required this.areaPoligono,
    required this.criadoEm,
    this.criadoPor,
    this.latitude,
    this.longitude,
    this.fotoUrl,
    this.direcao,
    this.distanciaMetros,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'nivelRisco': nivelRisco,
      'areaPoligono': areaPoligono
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'criadoEm': criadoEm,
      'criadoPor': criadoPor,
      'latitude': latitude,
      'longitude': longitude,
      'fotoUrl': fotoUrl,
      'direcao': direcao,
      'distanciaMetros': distanciaMetros,
    };
  }

  // Criar instância a partir de Map (Firestore/Realtime Database)
  factory IncendioModel.fromMap(String id, Map<String, dynamic> map) {
    final areaList = map['areaPoligono'] as List<dynamic>?;
    final poligono = areaList
            ?.map((e) {
              final lat = (e['latitude'] as num?)?.toDouble() ?? 0.0;
              final lng = (e['longitude'] as num?)?.toDouble() ?? 0.0;
              return LatLng(lat, lng);
            })
            .toList() ??
        [];

    return IncendioModel(
      id: id,
      descricao: map['descricao'] ?? '',
      nivelRisco: map['nivelRisco'] ?? '',
      areaPoligono: poligono,
      criadoEm: _parseCriadoEm(map['criadoEm']),
      criadoPor: map['criadoPor'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fotoUrl: map['fotoUrl'],
      direcao: (map['direcao'] as num?)?.toDouble(),
      distanciaMetros: (map['distanciaMetros'] as num?)?.toDouble(),
    );
  }

  static String _parseCriadoEm(dynamic raw) {
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw).toIso8601String();
    }
    if (raw is double) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt()).toIso8601String();
    }
    if (raw is String) {
      return raw;
    }
    return '';
  }
}
