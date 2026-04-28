enum DestinoAutenticacion {
  login,
  registro,
}

class AutenticacionControlador {
  Future<String> obtenerRuta(DestinoAutenticacion destino) async {
    switch (destino) {
      case DestinoAutenticacion.login:
        return '/login';
      case DestinoAutenticacion.registro:
        return '/registro';
    }
  }
}