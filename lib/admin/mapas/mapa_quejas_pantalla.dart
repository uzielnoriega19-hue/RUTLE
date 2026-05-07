import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';

const _gdl = LatLng(20.6736, -103.3440);

class MapaQuejasPantalla extends StatelessWidget {
  const MapaQuejasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapaWidget(centroFijo: _gdl, zoom: 12, mostrarCasa: false);
  }
}
