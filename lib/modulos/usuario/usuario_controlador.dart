import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioControlador {
  final TextEditingController nombreUsuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String fotoUrl = "";

  // Devuelve los datos en crudo; el widget los aplica a los controllers
  // solo si sigue montado, evitando el uso de controllers ya disposed.
  Future<Map<String, dynamic>?> cargarDatosUsuario() async {
    final uid = auth.currentUser!.uid;
    final doc = await firestore.collection("usuarios").doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  void aplicarDatos(Map<String, dynamic> data) {
    nombreUsuarioController.text = data["nombreUsuario"] ?? "";
    correoController.text = data["correo"] ?? "";
    final direccion = data["direccion"] ?? "";
    final colonia = data["colonia"] ?? "";
    direccionController.text = "$direccion, $colonia";
    final avatarId = data["avatarId"] ?? 1;
    fotoUrl = "https://api.dicebear.com/7.x/avataaars/png?seed=$avatarId";
  }

  void limpiar() {
    nombreUsuarioController.dispose();
    correoController.dispose();
    direccionController.dispose();
  }
}