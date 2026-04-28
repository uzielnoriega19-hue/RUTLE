import 'dart:math';

const List<int> avataresPermitidos = [
  2, 4, 5, 6, 9, 12, 14, 17, 18, 19,
  21, 25, 26, 31, 33, 34, 40, 45, 48,
  50, 54, 65, 68, 81, 100
];

class RegistroUIController {
  String email = "";
  String password = "";
  String confirmPassword = "";
  String nombreUsuario = "";
  String direccion = "";
  String colonia = "";

  late int avatarId;

  RegistroUIController() {
    final random = Random();
    avatarId = avataresPermitidos[random.nextInt(avataresPermitidos.length)];
  }

  void cambiarAvatar(int id) {
    avatarId = id;
  }
}