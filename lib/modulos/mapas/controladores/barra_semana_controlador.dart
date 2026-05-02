import 'package:flutter/material.dart';
import '../../../nucleo/rutas_app.dart';

// Paleta fija para rutas — mismos colores en modo claro y oscuro
const List<Color> rutaColores = [
  Color(0xFFE53935), // Rojo
  Color(0xFF1E88E5), // Azul
  Color(0xFF43A047), // Verde
  Color(0xFFFB8C00), // Naranja
  Color(0xFF8E24AA), // Morado
  Color(0xFF26C6DA), // Cyan
  Color(0xFFFFB300), // Ámbar
  Color(0xFF00897B), // Teal
];

Color colorParaRuta(String docId) =>
    rutaColores[docId.hashCode.abs() % rutaColores.length];

String prefKeyRuta(DestinoSemana dia) => 'ruta_sel_${dia.name}';

enum DestinoSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo,
}

class BarraSemanaControlador {
  Future<String> obtenerRuta(DestinoSemana destino) async {
    return RutasApp.seleccionarDia;
  }
}