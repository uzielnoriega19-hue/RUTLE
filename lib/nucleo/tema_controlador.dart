import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTemaKey = 'rutle_tema_modo';

class TemaControlador extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  // Carga la preferencia guardada. Si no hay ninguna, usa el sistema.
  Future<void> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getString(_kTemaKey);
      _modo = switch (guardado) {
        'oscuro' => ThemeMode.dark,
        'claro' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    } catch (_) {
      _modo = ThemeMode.system;
    }
    notifyListeners();
  }

  // Devuelve true si el modo oscuro está activo (ya sea por elección o por sistema).
  bool esOscuroEfectivo(BuildContext context) {
    if (_modo == ThemeMode.dark) return true;
    if (_modo == ThemeMode.light) return false;
    // ThemeMode.system: seguir el brillo de la plataforma
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  Future<void> setModo(bool oscuro) async {
    _modo = oscuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTemaKey, oscuro ? 'oscuro' : 'claro');
    } catch (_) {
      // Si no se puede guardar, el cambio aplica solo en esta sesión
    }
  }
}
