import 'package:flutter/material.dart';
import 'package:birthday_calendar/services/firestore_services.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Controllers para los inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  // Nombre original (para detectar cambios de ID)
  String originalName = '';

  // Service de Firestore
  final firestoreService = FirestoreService();

  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializamos solo una vez los datos recibidos por navegación
    if (!initialized) {
      final Map argumentos =
          ModalRoute.of(context)!.settings.arguments as Map;

      nameController.text = argumentos['nombre'];
      birthdayController.text = argumentos['cumpleaños'];
      originalName = argumentos['nombre'];

      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar simple y limpia
      appBar: AppBar(
        title: const Text('Editar cumpleaños'),
        centerTitle: true,
      ),

      // Fondo con padding general
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),

        // Fondo suave en vez de rojo (más UX friendly)
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
        ),

        // Centra la card en pantalla
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              // CONTENIDO DEL FORMULARIO
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Editar cumpleaños",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // INPUT NOMBRE
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // INPUT CUMPLEAÑOS
                  TextField(
                    controller: birthdayController,
                    decoration: const InputDecoration(
                      labelText: "Cumpleaños",
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BOTÓN ACTUALIZAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Actualizar"),
                      onPressed: () async {
                        // Si cambia el nombre, borramos el documento antiguo
                        if (originalName != nameController.text) {
                          await firestoreService
                              .deleteBirthdayFirestore(originalName);
                        }

                        // Guardamos nuevo/actualizado
                        await firestoreService.saveBirthday(
                          nameController.text,
                          birthdayController.text,
                        );

                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTÓN BORRAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Borrar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        await firestoreService.deleteBirthdayFirestore(
                          nameController.text,
                        );

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberamos memoria de los controllers
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}