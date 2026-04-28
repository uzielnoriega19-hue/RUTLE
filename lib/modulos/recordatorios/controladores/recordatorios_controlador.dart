import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecordatoriosControlador {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> obtenerRecordatoriosDesdeUno() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return firestore
        .collection('recordatorios')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> eliminarRecordatorio(String docId) async {
    await firestore
        .collection('recordatorios')
        .doc(docId)
        .delete();
  }
}