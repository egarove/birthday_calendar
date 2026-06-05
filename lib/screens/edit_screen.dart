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
  
  // Form key para validación
  final _formKey = GlobalKey<FormState>();

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
              child: Form(
                key: _formKey,
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
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El nombre es requerido";
                        }
                        if (value.length < 2) {
                          return "El nombre debe tener al menos 2 caracteres";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // INPUT CUMPLEAÑOS
                    TextFormField(
                      controller: birthdayController,
                      decoration: const InputDecoration(
                        labelText: "Cumpleaños",
                        hintText: "01-12",
                        helperText: "Formato día-mes (dd-mm)",
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "La fecha es requerida";
                        }
                        if (!_isValidDateFormat(value)) {
                          return "Formato inválido. Usa dd-mm (ej: 01-12)";
                        }
                        return null;
                      },
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
                          if (_formKey.currentState!.validate()) {
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

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
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

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidDateFormat(String date) {
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[012])$');
    if (!regex.hasMatch(date)) {
      return false;
    }
    
    final parts = date.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    
    // Validar rangos válidos
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return false;
    }
    
    // Validar días por mes
    final daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (day > daysInMonth[month - 1]) {
      return false;
    }
    
    return true;
  }

  @override
  void dispose() {
    // Liberamos memoria de los controllers
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}