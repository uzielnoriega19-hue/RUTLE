import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarRecordatorioControlador {
  Future<int> obtenerIdDisponible(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recordatorios')
        .where('uid', isEqualTo: uid)
        .get();

    final usados = snapshot.docs
        .map((doc) => doc['idRecordatorio'] as int)
        .toList();
    int id = 1;

    while (usados.contains(id)) {
      id++;
    }
    return id;
  }

  Future<String> obtenerDireccionUsuario(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    return doc.data()?['direccion'] ?? "Sin dirección";
  }

  Future<void> guardarRecordatorio({
    required String titulo,
    required String descripcion,
    required int minutosAntes,
    required String dia,
    required String ruta,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final idRecordatorio = await obtenerIdDisponible(uid);
    final direccion = await obtenerDireccionUsuario(uid);
    final fechaEvento = DateTime.now();

    await FirebaseFirestore.instance
        .collection('recordatorios')
        .add({

      "uid": uid,
      "descripcion": descripcion,
      "estado": "activo",
      "fechaEvento": Timestamp.fromDate(fechaEvento),
      "idRecordatorio": idRecordatorio,
      "lugar": direccion,
      "recordatorioAntes": minutosAntes,
      "titulo": titulo,
      "dia": dia,
      "ruta": ruta,

    });

  }

}