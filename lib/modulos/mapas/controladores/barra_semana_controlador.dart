import '../../../nucleo/rutas_app.dart';
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