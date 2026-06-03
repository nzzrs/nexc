import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const settings = InitializationSettings(android: androidInit, iOS: iosInit);
  await plugin.initialize(settings: settings);
}
