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
      print("No se pudo obtener la zona horaria local, usando UTC por defecto: $e");
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
        print("Notificación presionada con payload: ${details.payload}");
      },
    );

    _isInitialized = true;
  }

  /// Solicita permisos tanto para Firebase Cloud Messaging como para notificaciones locales
  Future<void> requestPermissions() async {
    // Permisos FCM
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Permisos locales en Android 13+
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
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

  /// Recupera los cumpleaños desde Firestore y programa las notificaciones
  Future<void> scheduleBirthdayNotifications() async {
    // Asegurarse de que esté inicializado
    await initialize();

    // 1. Cancelar todas las notificaciones previamente programadas para evitar duplicados
    await _localNotifications.cancelAll();
    print("Todas las notificaciones previas han sido canceladas.");

    // 2. Obtener lista de cumpleaños de Firestore
    final firestoreService = FirestoreService();
    final List birthdays = await firestoreService.getBirthdays();

    final now = tz.TZDateTime.now(tz.local);

    // Configuración para Android e iOS
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cumpleanos_channel_id',
      'Cumpleaños',
      channelDescription: 'Notificaciones para recordatorios de cumpleaños',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

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

        // Programar para las 9:00 AM del día del cumpleaños
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          month,
          day,
          9,
          0,
        );

        // Si el cumpleaños de este año ya pasó, programarlo para el próximo año
        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime(
            tz.local,
            now.year + 1,
            month,
            day,
            9,
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
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );

        print("Programada notificación para $name el $scheduledDate con ID $notificationId");
      } catch (e) {
        print("Error programando notificación para $name ($birthdayStr): $e");
      }
    }
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print("Todas las notificaciones locales han sido canceladas.");
  }

  /// Muestra una notificación instantánea de prueba
  Future<void> showTestNotification() async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel_id',
      'Prueba de Notificaciones',
      channelDescription: 'Canal para probar las notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      99999,
      '¡Prueba exitosa! 🚀',
      'Si estás leyendo esto, las notificaciones locales están configuradas correctamente.',
      platformDetails,
    );
    print("Notificación de prueba enviada.");
  }
}