import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/wind_data.dart';

/// Serviço para obter dados meteorológicos em tempo real
/// Utiliza a API gratuita Open-Meteo para consultar dados de vento, temperatura e umidade
class WindService {
  /// URL base da API Open-Meteo
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Timeout padrão para requisições HTTP (10 segundos)
  static const Duration _timeout = Duration(seconds: 10);

  /// Obtém dados de vento e clima para uma localização específica
  ///
  /// Parâmetros:
  /// - [latitude]: Coordenada de latitude do local
  /// - [longitude]: Coordenada de longitude do local
  ///
  /// Retorna WindData com velocidade/direção do vento, temperatura e umidade
  /// Retorna null se houver erro na requisição ou timeout
  Future<WindData?> getWindData(double latitude, double longitude) async {
    try {
      // Constrói a URL com parâmetros da API Open-Meteo
      // current=... especifica quais variáveis meteorológicas queremos
      final url = Uri.parse(
        '$_baseUrl?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m&'
        // A API retorna km/h por padrão; WindData espera m/s
        'wind_speed_unit=ms',
      );

      print('🌐 Requisitando dados de vento: $url');

      // Faz requisição HTTP com timeout de 10s
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // A resposta da API tem estrutura: { "current": { ... } }
        if (data['current'] != null) {
          final windData = WindData.fromJson(data['current']);
          print('✅ Dados de vento obtidos: $windData');
          return windData;
        }
      } else {
        print('❌ Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao obter dados de vento: $e');
    }

    return null;
  }
}
