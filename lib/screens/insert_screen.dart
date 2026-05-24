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
                      hintText: "01-12",
                      helperText: "Formato día-mes",
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                    ),
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
                        // Guardamos en Firestore
                        await firestoreService.saveBirthday(
                          nameController.text,
                          birthdayController.text,
                        );

                        // Volvemos atrás
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
    // Liberar memoria de controllers
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}