import 'package:flutter/foundation.dart';

import '../model/wind_data.dart';
import 'ndvi_service.dart';
import 'wind_service.dart';

/// Serviço para estimar o nível de risco de um incêndio
///
/// Combina condições meteorológicas (umidade, temperatura e vento) com a
/// densidade de vegetação (NDVI) em uma pontuação de 0 a 11 pontos:
/// - 0 a 3: Baixo
/// - 4 a 6: Médio
/// - 7 a 11: Alto
class RiscoService {
  static const String baixo = 'Baixo';
  static const String medio = 'Médio';
  static const String alto = 'Alto';

  final WindService _windService = WindService();
  final NDVIService _ndviService = NDVIService();

  /// Calcula o nível de risco para uma localização
  ///
  /// Retorna 'Médio' se os dados meteorológicos não estiverem disponíveis,
  /// para não bloquear o registro do incêndio.
  Future<String> calcularNivelRisco(double latitude, double longitude) async {
    final windData = await _windService.getWindData(latitude, longitude);
    if (windData == null) {
      debugPrint('⚠️ Sem dados de vento, usando risco padrão: $medio');
      return medio;
    }

    final ndvi = await _ndviService.getNDVIIndex(latitude, longitude);
    final nivel = classificar(windData, ndvi);

    debugPrint('🔥 Nível de risco calculado: $nivel ($windData, NDVI: $ndvi)');
    return nivel;
  }

  /// Classifica o risco a partir dos dados de vento e do índice NDVI
  static String classificar(WindData windData, double ndvi) {
    final pontos = _pontuarUmidade(windData.humidity) +
        _pontuarTemperatura(windData.temperature) +
        _pontuarVento(windData.windSpeed) +
        _pontuarVegetacao(ndvi);

    if (pontos >= 7) return alto;
    if (pontos >= 4) return medio;
    return baixo;
  }

  /// Ar seco favorece ignição e propagação (umidade relativa em %)
  static int _pontuarUmidade(double umidade) {
    if (umidade < 30) return 3;
    if (umidade < 50) return 2;
    if (umidade < 70) return 1;
    return 0;
  }

  /// Temperatura do ar em °C
  static int _pontuarTemperatura(double temperatura) {
    if (temperatura >= 32) return 3;
    if (temperatura >= 27) return 2;
    if (temperatura >= 22) return 1;
    return 0;
  }

  /// Velocidade do vento em m/s
  static int _pontuarVento(double velocidade) {
    if (velocidade >= 8) return 3;
    if (velocidade >= 5) return 2;
    if (velocidade >= 2) return 1;
    return 0;
  }

  /// Densidade de vegetação (combustível disponível)
  static int _pontuarVegetacao(double ndvi) {
    if (ndvi >= 0.6) return 2;
    if (ndvi >= 0.4) return 1;
    return 0;
  }
}
