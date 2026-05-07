import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rutle_test/firebase_options.dart';

class CrearAdminRecolectorControlador {
  Future<int> _siguienteIdEmpleado() async {
    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('rol', whereIn: ['admin', 'recolector'])
        .get();
    int max = 0;
    for (final doc in snap.docs) {
      final id = (doc.data()['idEmpleado'] as int?) ?? 0;
      if (id > max) max = id;
    }
    return max + 1;
  }

  // horario: {'Lunes': {'inicio': '07:00', 'fin': '15:00'}, ...}
  Future<String> crearUsuario({
    required String nombreUsuario,
    required String correo,
    required String password,
    required String rol,
    Map<String, Map<String, String>>? horario,
  }) async {
    FirebaseApp? app;
    try {
      // App secundaria para no cerrar la sesión del admin actual
      final appName = 'crear_${DateTime.now().millisecondsSinceEpoch}';
      app = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final auth = FirebaseAuth.instanceFor(app: app);
      final cred = await auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: password.trim(),
      );

      final uid = cred.user!.uid;
      final idEmpleado = await _siguienteIdEmpleado();

      final Map<String, dynamic> datos = {
        'idUsuario': uid,
        'idEmpleado': idEmpleado,
        'correo': correo.trim(),
        'nombreUsuario': nombreUsuario.trim(),
        'rol': rol,
        'avatarId': 0,
        'fotoUsuario':
            'https://api.dicebear.com/7.x/avataaars/png?seed=${nombreUsuario.trim()}',
        'fechaRegistro': FieldValue.serverTimestamp(),
        'reportes': 0,
      };

      if (rol == 'recolector' && horario != null && horario.isNotEmpty) {
        datos['horario'] = horario;
      }

      // Guardar en colección 'usuarios' usando la app principal (sin afectar sesión)
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set(datos);

      await auth.signOut();
      return 'OK';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este correo ya está registrado';
      }
      if (e.code == 'weak-password') {
        return 'La contraseña debe tener al menos 6 caracteres';
      }
      if (e.code == 'invalid-email') return 'Correo inválido';
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error inesperado: $e';
    } finally {
      await app?.delete();
    }
  }
}
