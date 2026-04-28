import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarPerfilControlador {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nombreUsuarioController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  String colonia = "";
  String fotoUrl = "";
  int avatarId = 1;

  Future<void> cargarDatos() async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore.collection("usuarios").doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      nombreUsuarioController.text = data["nombreUsuario"] ?? "";
      colonia = data["colonia"] ?? "";

      // Cargamos solo calle y número para editar
      direccionController.text = data["direccion"] ?? "";

      avatarId = data["avatarId"] ?? 1;
      fotoUrl = _generarUrlAvatar(avatarId);
    }
  }

  Future<void> guardarCambios() async {
    final uid = auth.currentUser!.uid;

    final direccion = direccionController.text.trim();
    final nombre = nombreUsuarioController.text.trim();

    // direccionCompleta = solo calle + colonia
    final direccionCompleta = "$direccion, $colonia";

    await firestore.collection("usuarios").doc(uid).update({
      "nombreUsuario": nombre,
      "direccion": direccion,
      "direccionCompleta": direccionCompleta,
      "avatarId": avatarId,
    });
  }

  void setAvatar(int id) {
    avatarId = id;
    fotoUrl = _generarUrlAvatar(id);
  }

  String _generarUrlAvatar(int id) {
    return "https://api.dicebear.com/7.x/avataaars/png?seed=$id";
  }

  void limpiar() {
    nombreUsuarioController.dispose();
    direccionController.dispose();
  }
}