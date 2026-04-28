import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForoControlador {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> crearForo({
    required String titulo,
    required String descripcion,
    required String privacidad,
    required List<Map<String, String>> rutas,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    if (titulo.trim().isEmpty || descripcion.trim().isEmpty) {
      throw Exception("Campos obligatorios vacíos");
    }

    if (rutas.isEmpty) {
      throw Exception("Debes agregar al menos una ruta antes de crear el foro");
    }

    final userDoc = await _db.collection('usuarios').doc(user.uid).get();

    if (!userDoc.exists) {
      throw Exception("No se encontró información del usuario");
    }

    final nombreUsuario = userDoc.data()?['nombreUsuario'] ?? 'Usuario';

    await _db.collection('foros').add({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'privacidad': privacidad,

      'creadorId': user.uid,
      'creadorNombre': nombreUsuario,

      'miembros': [
        {
          'uid': user.uid,
          'nombre': nombreUsuario,
        }
      ],

      'rutas': rutas,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }
}