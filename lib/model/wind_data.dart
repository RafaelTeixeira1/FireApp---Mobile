/// Modelo que representa os dados meteorológicos de vento
/// Usado para calcular a direção e intensidade da propagação do fogo
class WindData {
  /// Velocidade do vento em metros por segundo
  final double windSpeed;

  /// Direção do vento em graus (0-360, onde 0° = Norte)
  final double windDirection;

  /// Temperatura do ar em graus Celsius
  final double temperature;

  /// Umidade relativa do ar em percentual (0-100)
  final double humidity;

  /// Construtor com todos os parâmetros obrigatórios
  WindData({
    required this.windSpeed,
    required this.windDirection,
    required this.temperature,
    required this.humidity,
  });

  /// Cria uma instância de WindData a partir de um mapa JSON
  /// Usado para parsear resposta da API Open-Meteo
  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      windSpeed: (json['wind_speed_10m'] ?? 0).toDouble(),
      windDirection: (json['wind_direction_10m'] ?? 0).toDouble(),
      temperature: (json['temperature_2m'] ?? 0).toDouble(),
      humidity: (json['relative_humidity_2m'] ?? 0).toDouble(),
    );
  }

  /// Converte WindData para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  @override
  String toString() {
    return 'WindData(speed: ${windSpeed.toStringAsFixed(1)} m/s, '
        'direction: ${windDirection.toStringAsFixed(0)}°, '
        'temp: ${temperature.toStringAsFixed(1)}°C, '
        'humidity: ${humidity.toStringAsFixed(0)}%)';
  }
}
