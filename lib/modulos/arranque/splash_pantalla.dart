import 'package:flutter/material.dart';
import 'splash_controlador.dart';

class SplashPantalla extends StatefulWidget {
  const SplashPantalla({super.key});

  @override
  State<SplashPantalla> createState() => _SplashPantallaState();
}

class _SplashPantallaState extends State<SplashPantalla> {

  final SplashControlador _controlador = SplashControlador();

  @override
  void initState() {
    super.initState();
    _iniciarFlujo();
  }

  Future<void> _iniciarFlujo() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final ruta = await _controlador.obtenerRutaDestino();

    Navigator.pushNamedAndRemoveUntil(
      context,
      ruta,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'lib/recursos/imagenes/rutle_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}