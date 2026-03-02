import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _nearbyChannel = AndroidNotificationChannel(
    'nearby_incendio_channel',
    'Incêndios próximos',
    description: 'Alertas de incêndios próximos ao usuário',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_nearbyChannel);
  }

  static Future<void> showNearbyIncendio({
    required String id,
    required String titulo,
    required String corpo,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _nearbyChannel.id,
      _nearbyChannel.name,
      channelDescription: _nearbyChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(id.hashCode & 0x7fffffff, titulo, corpo, details, payload: id);
  }
}
