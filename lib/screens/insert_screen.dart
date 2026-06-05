import 'package:flutter/material.dart';
import 'package:birthday_calendar/services/firestore_services.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({Key? key}) : super(key: key);

  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  // Service de Firestore
  final firestoreService = FirestoreService();

  // Controllers de los inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  
  // Form key para validación
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: const Text('Añadir cumpleaños'),
        centerTitle: true,
      ),

      // CUERPO
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Fondo suave en lugar de rojo (mejor UX)
        color: Colors.grey.shade100,

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            // CARD PRINCIPAL
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

              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TÍTULO
                    const Text(
                      "Nuevo cumpleaños",
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

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Añadir"),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Guardamos en Firestore
                            await firestoreService.saveBirthday(
                              nameController.text,
                              birthdayController.text,
                            );

                            // Volvemos atrás
                            if (mounted) {
                              Navigator.pop(context);
                            }
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
    // Liberar memoria de controllers
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}