import '../model/fire_propagation_data.dart';
import 'wind_service.dart';
import 'ndvi_service.dart';

/// Serviço para calcular a propagação do fogo baseado em vento e vegetação
///
/// Utiliza um modelo simplificado que divide a propagação em 4 zonas:
/// 1. Zona Primária: direção do vento (maior velocidade de propagação)
/// 2. Zonas Secundárias (2): laterais ao vento (velocidade média)
/// 3. Zona Terciária: contra o vento (menor velocidade de propagação)
class FirePropagationService {
  final WindService _windService = WindService();
  final NDVIService _ndviService = NDVIService();

  /// Calcula as zonas de propagação do fogo para uma localização
  ///
  /// Parâmetros:
  /// - [latitude]: Latitude do centro do incêndio
  /// - [longitude]: Longitude do centro do incêndio
  ///
  /// Retorna FirePropagationData com 4 zonas de propagação ou null se erro
  Future<FirePropagationData?> calculate(
    double latitude,
    double longitude,
  ) async {
    try {
      // 1. Obtém dados de vento
      final windData = await _windService.getWindData(latitude, longitude);
      if (windData == null) {
        print('⚠️ Não foi possível obter dados de vento');
        return null;
      }

      // 2. Calcula NDVI (densidade de vegetação)
      final ndvi = await _ndviService.getNDVIIndex(latitude, longitude);

      // 3. Calcula distância base de propagação
      // Fórmula: velocidade do vento (m/s) * 300 * fator NDVI
      // Quanto maior o NDVI, mais vegetação e mais rápida a propagação
      final baseDistance = windData.windSpeed * 300 * (0.5 + ndvi * 0.5);

      print(
        '🔥 Distância base de propagação: ${baseDistance.toStringAsFixed(0)} m '
        '(vento: ${windData.windSpeed} m/s, NDVI: ${ndvi.toStringAsFixed(3)})',
      );

      // 4. Cria as 4 zonas de propagação
      final zones = <PropagationZone>[
        // Zona Primária: direção do vento ±30°, distância máxima 1.5x
        PropagationZone(
          name: 'Zona Primária',
          startAngle: _normalizeAngle(windData.windDirection - 30),
          endAngle: _normalizeAngle(windData.windDirection + 30),
          maxDistanceMeters: baseDistance * 1.5,
          intensity: 1.0,
          isPrimary: true,
        ),

        // Zona Secundária Esquerda: 30° a 110° do vento (lateral esquerda)
        PropagationZone(
          name: 'Zona Secundária Esquerda',
          startAngle: _normalizeAngle(windData.windDirection + 30),
          endAngle: _normalizeAngle(windData.windDirection + 110),
          maxDistanceMeters: baseDistance * 1.1,
          intensity: 0.6,
        ),

        // Zona Secundária Direita: -110° a -30° do vento (lateral direita)
        PropagationZone(
          name: 'Zona Secundária Direita',
          startAngle: _normalizeAngle(windData.windDirection - 110),
          endAngle: _normalizeAngle(windData.windDirection - 30),
          maxDistanceMeters: baseDistance * 1.1,
          intensity: 0.6,
        ),

        // Zona Terciária: 110° a 250° do vento (contra o vento)
        // Dividida em duas partes para evitar cruzar 360°/0°
        PropagationZone(
          name: 'Zona Terciária',
          startAngle: _normalizeAngle(windData.windDirection + 110),
          endAngle: _normalizeAngle(windData.windDirection + 250),
          maxDistanceMeters: baseDistance * 0.6,
          intensity: 0.3,
        ),
      ];

      return FirePropagationData(
        centerLat: latitude,
        centerLng: longitude,
        windSpeed: windData.windSpeed,
        windDirection: windData.windDirection,
        ndvi: ndvi,
        zones: zones,
      );
    } catch (e) {
      print('❌ Erro ao calcular propagação: $e');
      return null;
    }
  }

  /// Normaliza um ângulo para o intervalo 0-360 graus
  double _normalizeAngle(double angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
  }
}
