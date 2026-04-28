import 'package:flutter/material.dart';
import 'package:rutle_test/nucleo/rutas_app.dart';

class ForosControlador {
  void irMisForos(BuildContext context) {
    Navigator.pushNamed(
      context,
      RutasApp.misForos,
    );
  }

  void irBuscarForos(BuildContext context) {
    Navigator.pushNamed(
      context,
      RutasApp.nuevosForos,
    );
  }

  Future<dynamic> irCrearForo(BuildContext context) async {
    return await Navigator.pushNamed(context, RutasApp.crearForo);
  }
}