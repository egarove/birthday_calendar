import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;  

  Future<void> saveBirthday(String name, String birthday) async {
    final uid = authentication.currentUser!.uid;
    final data = <String, dynamic>{
      'nombre': name,
      'cumpleaños': birthday,
    };
    await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('cumpleaños')
        .doc(name)
        .set(data);
  }

  // devuelve los cumpleaños del usuario actual
  Future<List> getBirthdays() async {
    List birthdays = [];

    final uid = authentication.currentUser!.uid;
    CollectionReference collectionReferenceBirthdays = firestore.collection('usuarios').doc(uid).collection('cumpleaños');

    QuerySnapshot queryBirthdays = await collectionReferenceBirthdays.get();
    for (var documento in queryBirthdays.docs) {
      final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
      final birthday = {
        "nombre": data['nombre'],
        "cumpleaños": data['cumpleaños']
      };
      birthdays.add(birthday);
    } 
    //ordenamos los cumpleaños antes de devolverlos
    birthdays.sort((birth1, birth2) {
      final now = DateTime.now();

      DateTime nextBirthday(String birthday) {
          final parts = birthday.split('-');

          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);

          var date = DateTime(
            now.year,
            month,
            day,
          );

          // Si ya pasó este año, usar el año siguiente
          if (date.isBefore(now)) {
            date = DateTime(
              now.year + 1,
              month,
              day,
            );
          }

          return date;
        }

      final date1 = nextBirthday(birth1['cumpleaños']);
      final date2 = nextBirthday(birth2['cumpleaños']);

    return date1.compareTo(date2);
    });
    return birthdays;
  }

  // Eliminar cumpleaños de Firestore
  Future<void> deleteBirthdayFirestore(String name) async {
    final uid = authentication.currentUser!.uid;
    await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('cumpleaños')
        .doc(name)
        .delete();
  }
}