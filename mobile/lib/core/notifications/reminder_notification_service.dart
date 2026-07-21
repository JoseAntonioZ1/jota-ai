import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// FR-03.3. docs/03_NON_FUNCTIONAL_REQUIREMENTS.md NFR-24: el objetivo
/// real es Android; en otras plataformas usadas solo para desarrollo
/// (p. ej. Windows) las llamadas se ignoran si el plugin no esta
/// soportado, sin bloquear la creacion del recordatorio.
class ReminderNotificationService {
  ReminderNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // Plataforma sin soporte para notificaciones (p. ej. Windows en desarrollo).
    }
  }

  Future<void> scheduleForReminder({
    required String reminderId,
    required String description,
    required DateTime scheduledAt,
  }) async {
    if (!_initialized || scheduledAt.isBefore(DateTime.now())) return;
    try {
      // NFR-15: se pide el permiso justo cuando se usa por primera vez la
      // funcionalidad (crear un recordatorio), no de antemano en bloque.
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _plugin.zonedSchedule(
        _notificationId(reminderId),
        'JOTA',
        description,
        tz.TZDateTime.from(scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'jota_reminders',
            'Recordatorios',
            channelDescription: 'Recordatorios de JOTA',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // No bloquea la creacion/edicion del recordatorio en el backend.
    }
  }

  Future<void> cancelForReminder(String reminderId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_notificationId(reminderId));
    } catch (_) {}
  }

  int _notificationId(String reminderId) => reminderId.hashCode & 0x7fffffff;
}
