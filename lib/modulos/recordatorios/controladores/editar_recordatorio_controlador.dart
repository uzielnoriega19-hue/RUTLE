import 'package:cloud_firestore/cloud_firestore.dart';

class EditarRecordatorioControlador {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> obtenerRecordatorio(String idDoc) async {
    final doc = await _db
        .collection("recordatorios")
        .doc(idDoc)
        .get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data["id"] = doc.id;
    return data;
  }

  Future<void> actualizarRecordatorio({
    required String idDoc,
    required String titulo,
    required String descripcion,
    required int minutosAntes,
    required String dia,
    required String ruta,
  }) async {

    await _db
        .collection("recordatorios")
        .doc(idDoc)
        .update({
      "titulo": titulo,
      "descripcion": descripcion,
      "recordatorioAntes": minutosAntes,
      "dia": dia,
      "ruta": ruta,
    });
  }
}