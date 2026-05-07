import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DestinoLogin {
  mainTab,
  registro,
}

class LoginControlador {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      // VALIDACIONES BÁSICAS
      if (email.trim().isEmpty) return 'Falta el correo';
      if (password.trim().isEmpty) return 'Falta la contraseña';

      if ('@'.allMatches(email).length != 1) {
        return 'El correo debe tener exactamente un @';
      }

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email)) {
        return 'Formato de correo inválido';
      }

      // 🔐 INTENTO NORMAL CON FIREBASE AUTH
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = cred.user;

      if (user == null) {
        return 'Error al iniciar sesión';
      }

      await user.reload();

      // 🔎 BUSCAR DATOS EN FIRESTORE POR UID
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = userDoc.data();

      // 🧠 ENRUTAMIENTO POR ROL
      final rol = data?['rol'] as String?;

      if (rol == 'admin') return '/mainTabAdmin';
      if (rol == 'recolector') return '/mainTabRecolector';

      // 📩 VERIFICACIÓN DE CORREO (solo usuarios normales)
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        await _auth.signOut();
        return 'Debes verificar tu correo antes de iniciar sesión';
      }

      return '/mainTab';

    } on FirebaseAuthException catch (e) {

      // 🚨 SI NO EXISTE EN AUTH → BUSCAR EN FIRESTORE
      if (e.code == 'user-not-found') {

        final query = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('correo', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();

          final rol = data['rol'] as String?;
          if (rol == 'admin') return '/mainTabAdmin';
          if (rol == 'recolector') return '/mainTabRecolector';
        }

        return 'No existe una cuenta con este correo';
      }

      if (e.code == 'wrong-password') {
        return 'Contraseña incorrecta';
      }

      if (e.code == 'invalid-email') {
        return 'Correo inválido';
      }

      if (e.code == 'user-disabled') {
        return 'Esta cuenta ha sido deshabilitada';
      }

      if (e.code == 'too-many-requests') {
        return 'Demasiados intentos. Intenta más tarde';
      }

      return 'Error: ${e.message}';

    } catch (e) {
      return 'Error inesperado';
    }
  }

  Future<String> obtenerRuta(DestinoLogin destino) async {
    switch (destino) {
      case DestinoLogin.mainTab:
        return '/mainTab';
      case DestinoLogin.registro:
        return '/registro';
    }
  }
}