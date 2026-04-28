import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/autenticacion/autenticacion_controlador.dart';

class AutenticacionPantalla extends StatefulWidget {
  const AutenticacionPantalla({super.key});

  @override
  State<AutenticacionPantalla> createState() => _AutenticacionPantallaState();
}

class _AutenticacionPantallaState extends State<AutenticacionPantalla> {

  final AutenticacionControlador _controlador = AutenticacionControlador();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    final horizontalPadding = size.width * 0.08;
    final tituloFontSize = size.width * 0.12;
    final botonAltura = size.height * 0.07;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [

              SizedBox(height: size.height * 0.18),

              Text(
                'RUTLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: tituloFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: tituloFontSize * 0.08,
                ),
              ),

              SizedBox(height: size.height * 0.12),

              SizedBox(
                width: double.infinity,
                height: botonAltura,
                child: ElevatedButton(
                  onPressed: () async {

                    final ruta = await _controlador.obtenerRuta(
                      DestinoAutenticacion.login,
                    );

                    if (!mounted) return;

                    Navigator.pushNamed(context, ruta);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        botonAltura * 0.25,
                      ),
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: botonAltura * 0.4,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.025),

              SizedBox(
                width: double.infinity,
                height: botonAltura,
                child: OutlinedButton(
                  onPressed: () async {

                    final ruta = await _controlador.obtenerRuta(
                      DestinoAutenticacion.registro,
                    );

                    if (!mounted) return;

                    Navigator.pushNamed(context, ruta);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        botonAltura * 0.25,
                      ),
                    ),
                  ),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: botonAltura * 0.4,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.18),

              SizedBox(
                width: double.infinity,
                height: botonAltura * 0.7,
                child: TextButton(
                  onPressed: () {

                    Navigator.pop(context);

                  },
                  child: Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: botonAltura * 0.35,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}