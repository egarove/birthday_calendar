import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;  

  Future<void> saveBirthday(String name, DateTime birthday) async {
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

  // Stream en tiempo real de los cumpleaños del usuario actual
  Stream<QuerySnapshot> streamBirthdays() {
    final uid = authentication.currentUser!.uid;
    return firestore
        .collection('usuarios')
        .doc(uid)
        .collection('cumpleaños')
        .snapshots();
  }

  // Eliminar cumpleaños de Firestore
  Future<void> deleteBirthdayFirestore(String name) async {
    final uid = authentication.currentUser!.uid;
    await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('apis')
        .doc(name)
        .delete();
  }
}