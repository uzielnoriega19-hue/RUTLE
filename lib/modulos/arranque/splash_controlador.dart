import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rutle_test/nucleo/rutas_app.dart';

class SplashControlador {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> obtenerRutaDestino() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return RutasApp.autenticacion;
    }

    try {
      await user.reload();
      final User? refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return RutasApp.autenticacion;
      }

      // 🔥 BUSCAR USUARIO EN FIRESTORE
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(refreshedUser.uid)
          .get();

      final data = userDoc.data();

      final esAdmin = data?['rol'] == 'admin';

      // 🚨 SI ES ADMIN → ENTRA DIRECTO
      if (esAdmin) {
        return RutasApp.mainTabAdmin;
      }

      // 📩 VALIDACIÓN NORMAL PARA USUARIOS
      if (!refreshedUser.emailVerified) {
        await _auth.signOut();
        return RutasApp.autenticacion;
      }

      return RutasApp.mainTab;

    } catch (_) {
      await _auth.signOut();
      return RutasApp.autenticacion;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}