import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Guardar usuario en Firestore
  Future<void> _saveUserInFirestore(User user) async {
    final userDoc = firestore.collection('usuarios').doc(user.uid);

    final docSnapshot = await userDoc.get();

    //Solo lo crea si no existe
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'email',
      });
    }
  }

  // Registro con email
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    final credential = await authentication.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Guardar en Firestore
    await _saveUserInFirestore(credential.user!);

    return credential;
  }

  // Login con email
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final credential = await authentication.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential;
  }

  // Google (login + registro automático)
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await authentication.signInWithCredential(credential);

    //Guardar en Firestore
    await _saveUserInFirestore(userCredential.user!);

    return userCredential;
  }

  // Logout
  Future<void> signOut() async {
    await Future.wait([
      authentication.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  // Usuario actual
  User? get currentUser => authentication.currentUser;

  //mandar correo para reestablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    await authentication.sendPasswordResetEmail(email: email);
  }
}