import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DestinoVerificacion {
  mainTab,
  registro,
}

class VerificacionCorreoControlador {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? _email;
  static String? _password;
  static int _reenvios = 0;

  static void setCredenciales(String email, String password) {
    _email = email;
    _password = password;
    _reenvios = 0;
  }

  Future<bool> _asegurarSesion() async {
    try {
      if (_auth.currentUser != null) return true;

      if (_email == null || _password == null) return false;

      await _auth.signInWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );

      return _auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  Future<String?> verificarCorreo() async {
    final sesionOk = await _asegurarSesion();
    if (!sesionOk) return null;

    User? usuario = _auth.currentUser;
    if (usuario == null) return null;

    await usuario.reload();
    usuario = _auth.currentUser;
    if (usuario == null) return null;

    if (!usuario.emailVerified) return null;

    await _db.collection('usuarios').doc(usuario.uid).update({
      "correoVerificado": true,
    });

    return '/mainTab';
  }

  Future<String> reenviarCorreo() async {
    if (_reenvios >= 3) return 'LIMITE';

    final sesionOk = await _asegurarSesion();
    if (!sesionOk) return 'No se pudo iniciar sesión. Verifica tu correo y contraseña.';

    try {
      final usuario = _auth.currentUser;
      if (usuario == null) return 'No se encontró el usuario.';

      await usuario.sendEmailVerification();
      _reenvios++;

      if (_reenvios >= 3) return 'LIMITE_ALCANZADO';

      return 'Correo enviado nuevamente';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return 'Espere un poco antes de intentar reenviar el correo nuevamente.';
      }
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error inesperado: ${e.toString()}';
    }
  }

  static void resetearReenvios() {
    _reenvios = 0;
  }

  Future<String> obtenerRuta(DestinoVerificacion destino) async {
    switch (destino) {
      case DestinoVerificacion.mainTab:
        return '/mainTab';
      case DestinoVerificacion.registro:
        return '/registro';
    }
  }
}