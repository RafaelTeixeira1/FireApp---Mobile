/// Modelo que representa uma zona de propagação do fogo
/// Cada zona tem um ângulo inicial/final, distância máxima e intensidade
class PropagationZone {
  /// Nome descritivo da zona (ex: "Zona Primária", "Zona Secundária Esquerda")
  final String name;

  /// Ângulo inicial da zona em graus (0-360)
  final double startAngle;

  /// Ângulo final da zona em graus (0-360)
  final double endAngle;

  /// Distância máxima que o fogo pode se propagar nesta zona em metros
  final double maxDistanceMeters;

  /// Intensidade da propagação (0.0 a 1.0)
  /// 1.0 = máxima intensidade, 0.3 = baixa intensidade
  final double intensity;

  /// Indica se esta é a zona primária (direção principal do vento)
  final bool isPrimary;

  PropagationZone({
    required this.name,
    required this.startAngle,
    required this.endAngle,
    required this.maxDistanceMeters,
    required this.intensity,
    this.isPrimary = false,
  });

  /// Converte PropagationZone para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startAngle': startAngle,
      'endAngle': endAngle,
      'maxDistanceMeters': maxDistanceMeters,
      'intensity': intensity,
      'isPrimary': isPrimary,
    };
  }

  /// Cria PropagationZone a partir de um mapa JSON
  factory PropagationZone.fromJson(Map<String, dynamic> json) {
    return PropagationZone(
      name: json['name'] ?? '',
      startAngle: (json['startAngle'] ?? 0).toDouble(),
      endAngle: (json['endAngle'] ?? 0).toDouble(),
      maxDistanceMeters: (json['maxDistanceMeters'] ?? 0).toDouble(),
      intensity: (json['intensity'] ?? 0).toDouble(),
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

/// Modelo completo que representa os dados de propagação do fogo
/// Contém informações sobre o centro do incêndio, vento, NDVI e as zonas de propagação
class FirePropagationData {
  /// Latitude do centro do incêndio
  final double centerLat;

  /// Longitude do centro do incêndio
  final double centerLng;

  /// Velocidade do vento em m/s
  final double windSpeed;

  /// Direção do vento em graus
  final double windDirection;

  /// Índice NDVI (densidade de vegetação) de 0.0 a 1.0
  final double ndvi;

  /// Lista de zonas de propagação calculadas
  /// Normalmente contém 4 zonas: 1 primária, 2 secundárias e 1 terciária
  final List<PropagationZone> zones;

  FirePropagationData({
    required this.centerLat,
    required this.centerLng,
    required this.windSpeed,
    required this.windDirection,
    required this.ndvi,
    required this.zones,
  });

  /// Converte FirePropagationData para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'centerLat': centerLat,
      'centerLng': centerLng,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'ndvi': ndvi,
      'zones': zones.map((z) => z.toJson()).toList(),
    };
  }

  /// Cria FirePropagationData a partir de um mapa JSON
  factory FirePropagationData.fromJson(Map<String, dynamic> json) {
    return FirePropagationData(
      centerLat: (json['centerLat'] ?? 0).toDouble(),
      centerLng: (json['centerLng'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      windDirection: (json['windDirection'] ?? 0).toDouble(),
      ndvi: (json['ndvi'] ?? 0).toDouble(),
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((z) => PropagationZone.fromJson(z))
              .toList() ??
          [],
    );
  }
}
