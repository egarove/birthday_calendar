import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:birthday_calendar/services/firestore_services.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  /// Inicializa las notificaciones locales y la base de datos de zonas horarias
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Inicializar zonas horarias
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Configurar notificaciones locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Callback cuando el usuario toca la notificación
      },
    );

    _isInitialized = true;
  }

  /// Solicita permisos tanto para Firebase Cloud Messaging como para notificaciones locales
  Future<void> requestPermissions() async {
    // Permisos FCM
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.getToken();

    // Permisos locales en Android 13+
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // Permisos locales en iOS
    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Configuración de notificación reutilizable para el canal de cumpleaños
  static const NotificationDetails _birthdayNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'cumpleanos_channel_id',
      'Cumpleaños',
      channelDescription: 'Notificaciones para recordatorios de cumpleaños',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Recupera los cumpleaños desde Firestore y programa las notificaciones.
  /// Devuelve el número de notificaciones programadas exitosamente.
  Future<int> scheduleBirthdayNotifications() async {
    await initialize();

    // Cancelar todas las notificaciones previamente programadas para evitar duplicados
    await _localNotifications.cancelAll();

    // Obtener lista de cumpleaños de Firestore
    final firestoreService = FirestoreService();
    final List birthdays = await firestoreService.getBirthdays();

    if (birthdays.isEmpty) return 0;

    final now = tz.TZDateTime.now(tz.local);
    int scheduledCount = 0;

    // Verificar si se tiene permiso para alarmas exactas
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    bool canScheduleExact = false;
    if (androidPlugin != null) {
      canScheduleExact = await androidPlugin.canScheduleExactNotifications() ?? false;
    }
    final androidScheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (var birthday in birthdays) {
      final String name = birthday['nombre'] ?? '';
      final String birthdayStr = birthday['cumpleaños'] ?? '';

      if (name.isEmpty || birthdayStr.isEmpty) continue;

      try {
        final parts = birthdayStr.split('-');
        if (parts.length < 2) continue;

        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);

        if (day == null || month == null) continue;

        // Programar para las 00:00 del día del cumpleaños
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          month,
          day,
          0,
          0,
        );

        // Si el cumpleaños de este año ya pasó, programarlo para el próximo año
        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime(
            tz.local,
            now.year + 1,
            month,
            day,
            0,
            0,
          );
        }

        // Generar un ID numérico único basado en el hash del nombre
        final int notificationId = name.hashCode.abs() % 100000;

        await _localNotifications.zonedSchedule(
          notificationId,
          '¡Hoy cumple años $name! 🎉',
          'No te olvides de desearle un feliz cumpleaños a $name.',
          scheduledDate,
          _birthdayNotificationDetails,
          androidScheduleMode: androidScheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );

        // Programar notificación de recordatorio el día anterior al cumpleaños a las 10:00
        try {
          // Calculamos el día anterior explícitamente a las 10:00 AM
          final birthdayYearForReminder = scheduledDate.year;
          final dayBefore = scheduledDate.subtract(const Duration(days: 1));
          var dayBeforeDate = tz.TZDateTime(
            tz.local,
            birthdayYearForReminder,
            dayBefore.month,
            dayBefore.day,
            10,
            0,
          );

          // Si ya pasó, programar para el año siguiente
          if (dayBeforeDate.isBefore(now)) {
            final nextYearDayBefore = tz.TZDateTime(
              tz.local,
              scheduledDate.year + 1,
              month,
              day,
              0,
              0,
            ).subtract(const Duration(days: 1));
            dayBeforeDate = tz.TZDateTime(
              tz.local,
              nextYearDayBefore.year,
              nextYearDayBefore.month,
              nextYearDayBefore.day,
              10,
              0,
            );
          }

          final int notificationIdBefore = (name.hashCode.abs() % 100000) + 100000;

          await _localNotifications.zonedSchedule(
            notificationIdBefore,
            '¡Mañana es el cumpleaños de $name! 🎁',
            '¿Le has comprado ya un regalo? No te olvides de felicitarle mañana.',
            dayBeforeDate,
            _birthdayNotificationDetails,
            androidScheduleMode: androidScheduleMode,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
          );
        } catch (e) {
          // Si falla la del día de antes, continuamos
        }

        scheduledCount++;
      } catch (e) {
        // Si falla una notificación individual, continuamos con las demás
      }
    }

    // Programar notificación de inactividad por 360 días
    try {
      final inactivityDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        10,
        0,
      ).add(const Duration(days: 360));

      await _localNotifications.zonedSchedule(
        99990,
        '¡Te echamos de menos! ❤️',
        'Entra en la app para mantener tus recordatorios de cumpleaños actualizados.',
        inactivityDate,
        _birthdayNotificationDetails,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Si falla la de inactividad, continuamos
    }

    return scheduledCount;
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Muestra una notificación instantánea de prueba (usa .show, siempre funciona)
  Future<void> showTestNotification() async {
    await initialize();

    const NotificationDetails platformDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel_id',
        'Prueba de Notificaciones',
        channelDescription: 'Canal para probar las notificaciones',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      99999,
      '¡Prueba exitosa! 🚀',
      'Si estás leyendo esto, las notificaciones locales están configuradas correctamente.',
      platformDetails,
    );
  }

  /// Programa una notificación de prueba con zonedSchedule para dentro de 15 segundos.
  /// Esto verifica que zonedSchedule funciona correctamente en el dispositivo.
  /// Devuelve la hora programada como String para mostrar al usuario.
  Future<String> showTestScheduledNotification() async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 15));

    // Verificar si se tiene permiso para alarmas exactas
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    bool canScheduleExact = false;
    if (androidPlugin != null) {
      canScheduleExact = await androidPlugin.canScheduleExactNotifications() ?? false;
    }
    final androidScheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _localNotifications.zonedSchedule(
      99998,
      '¡Prueba programada exitosa! ⏰',
      'Esta notificación se programó con zonedSchedule y llegó correctamente.',
      scheduledDate,
      _birthdayNotificationDetails,
      androidScheduleMode: androidScheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final timeStr = '${scheduledDate.hour.toString().padLeft(2, '0')}:'
        '${scheduledDate.minute.toString().padLeft(2, '0')}:'
        '${scheduledDate.second.toString().padLeft(2, '0')}';
    return timeStr;
  }
}