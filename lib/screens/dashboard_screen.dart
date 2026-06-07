import 'package:flutter/material.dart';
import 'package:birthday_calendar/services/firestore_services.dart';
import 'package:birthday_calendar/services/authentication_services.dart';
import 'package:birthday_calendar/theme/app_theme.dart';
import 'package:birthday_calendar/services/notification_services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Servicios
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final notificationService = NotificationService();

  // Future guardado para poder refrescar manualmente
  late Future<List> birthdaysFuture;

  @override
  void initState() {
    super.initState();

    // Registrar la última visita del usuario
    _updateLastVisit();

    // Cargamos los cumpleaños una sola vez al iniciar la pantalla
    birthdaysFuture = firestoreService.getBirthdays();

    // Inicializar y pedir permisos de notificaciones al arrancar
    _setupNotifications();
  }

  Future<void> _updateLastVisit() async {
    try {
      await firestoreService.updateLastVisit();
    } catch (e) {
      // Ignorar errores de red para no interrumpir el flujo del usuario
    }
  }

  Future<void> _setupNotifications() async {
    try {
      await notificationService.requestPermissions();
      final count = await notificationService.scheduleBirthdayNotifications();
      if (mounted) {
        _showSnackBar('🔔 Se han programado $count notificaciones de cumpleaños');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('⚠️ Error al programar notificaciones: $e', isError: true);
      }
    }
  }

  /// Refresca los datos desde Firestore y reprograma las notificaciones locales
  void refreshBirthdays() {
    setState(() {
      birthdaysFuture = firestoreService.getBirthdays();
    });
    _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      final count = await notificationService.scheduleBirthdayNotifications();
      if (mounted) {
        _showSnackBar('🔔 Se han actualizado $count notificaciones');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('⚠️ Error al reprogramar notificaciones: $e', isError: true);
      }
    }
  }

  /// Muestra un SnackBar informativo
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR PRINCIPAL
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Mis cumpleaños',
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Botones de acción
        actions: [
          //boton para cerrar sesion y borrar notificaciones
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.backgroundColor,),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              // Limpiar todas las notificaciones al cerrar sesión para evitar fugas de datos
              await notificationService.cancelAllNotifications();
              await authService.signOut();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      // CUERPO PRINCIPAL
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          // FUTURE BUILDER: carga datos de Firestore
          child: FutureBuilder(
            future: birthdaysFuture,
            builder: (context, snapshot) {

              // Estado de carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error en Firestore
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // Lista vacía
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, //posicion de los hijos Text
                    children: [
                      Icon(Icons.cake_rounded, size: 72, color: AppTheme.primaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes cumpleaños registrados',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pulsa el botón + para registar un cumpleaños!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // LISTA DE CUMPLEAÑOS
              return ListView.builder(
                itemCount: snapshot.data!.length,

                itemBuilder: (context, index) {
                  final birthday = snapshot.data![index];

                  return GestureDetector(
                    onTap: () async {
                      // Navegamos a editar y cuando vuelva refrescamos datos
                      await Navigator.pushNamed(
                        context,
                        'edit',
                        arguments: birthday,
                      );

                      // refresca datos al volver (despues de editar o insertar)
                      refreshBirthdays();
                    },

                    // TARJETA 
                    child: Card(                      
                      elevation: 10,
                      margin: const EdgeInsets.only(bottom: 10, right: 20, left: 20, top: 10),

                      child: ListTile(
                        title: Text(birthday['nombre']),

                        subtitle: Text(
                          birthday['cumpleaños'].toString(),
                        ),

                        trailing: const Icon(Icons.edit),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),

      // BOTÓN (crear cumpleaños)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Espera a que vuelva de crear
          await Navigator.pushNamed(context, 'insert');

          // refresca lista
          refreshBirthdays();
        },

        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Nuevo cumpleaños',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}