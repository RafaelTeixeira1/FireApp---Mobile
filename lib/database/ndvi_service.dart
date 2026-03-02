import 'dart:math';

/// Serviço para calcular o índice NDVI (Normalized Difference Vegetation Index)
///
/// Como não temos acesso a imagens de satélite em tempo real, usamos uma
/// heurística baseada na distância de áreas urbanas conhecidas
class NDVIService {
  /// Raio da Terra em quilômetros (usado na fórmula de Haversine)
  static const double _earthRadiusKm = 6371.0;

  /// Coordenadas de referência de centros urbanos (baixa vegetação)
  /// Formato: [latitude, longitude]
  static const List<List<double>> _urbanCenters = [
    [-23.5505, -46.6333], // São Paulo
    [-22.9068, -43.1729], // Rio de Janeiro
    [-19.9167, -43.9345], // Belo Horizonte
    [-25.4284, -49.2733], // Curitiba
  ];

  /// Calcula o índice NDVI estimado para uma localização
  ///
  /// O cálculo usa a fórmula de Haversine para determinar a distância
  /// até o centro urbano mais próximo. Quanto mais longe de áreas urbanas,
  /// maior é a densidade de vegetação estimada.
  ///
  /// Retorna um valor de 0.0 a 1.0:
  /// - 0.0 a 0.2: Solo exposto ou área urbana
  /// - 0.2 a 0.4: Vegetação esparsa
  /// - 0.4 a 0.6: Vegetação moderada
  /// - 0.6 a 0.8: Vegetação densa
  /// - 0.8 a 1.0: Vegetação muito densa (florestas)
  Future<double> getNDVIIndex(double latitude, double longitude) async {
    // Calcula distância até o centro urbano mais próximo
    double minDistance = double.infinity;

    for (var center in _urbanCenters) {
      final distance = _haversineDistance(
        latitude,
        longitude,
        center[0],
        center[1],
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // Converte distância em índice NDVI
    // Centros urbanos (0km) = NDVI 0.1
    // 50km de distância = NDVI 0.5
    // 100km+ de distância = NDVI 0.8
    double ndvi = 0.1 + (minDistance / 100.0) * 0.7;

    // Limita entre 0.1 e 0.9
    ndvi = ndvi.clamp(0.1, 0.9);

    print(
      '🌿 NDVI calculado: ${ndvi.toStringAsFixed(3)} '
      '(distância do centro urbano: ${minDistance.toStringAsFixed(1)} km)',
    );

    return ndvi;
  }

  /// Calcula a distância entre dois pontos usando a fórmula de Haversine
  ///
  /// Parâmetros:
  /// - lat1, lon1: Coordenadas do primeiro ponto
  /// - lat2, lon2: Coordenadas do segundo ponto
  ///
  /// Retorna a distância em quilômetros
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Converte graus para radianos
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    // Fórmula de Haversine
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1Rad) * cos(lat2Rad);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Converte graus para radianos
  double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
