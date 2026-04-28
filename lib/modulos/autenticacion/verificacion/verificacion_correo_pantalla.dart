import 'package:flutter/material.dart';
import 'verificacion_correo_controlador.dart';

class VerificacionCorreoPantalla extends StatefulWidget {
  const VerificacionCorreoPantalla({super.key});

  @override
  State<VerificacionCorreoPantalla> createState() =>
      _VerificacionCorreoPantallaState();
}

class _VerificacionCorreoPantallaState
    extends State<VerificacionCorreoPantalla> {

  final VerificacionCorreoControlador _controlador =
      VerificacionCorreoControlador();

  bool _cargando = false;

  String? email;
  String? password;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      email = args?['email'];
      password = args?['password'];

      if (email != null && password != null) {
        VerificacionCorreoControlador.setCredenciales(email!, password!);
      }
    });
  }

  Future<void> _verificarCorreo() async {
    setState(() => _cargando = true);

    final ruta = await _controlador.verificarCorreo();

    setState(() => _cargando = false);

    if (!mounted) return;

    if (ruta != null) {
      Navigator.pushNamedAndRemoveUntil(context, ruta, (route) => false);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Aún no has verificado tu correo'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _reenviarCorreo() async {
    final mensaje = await _controlador.reenviarCorreo();

    if (!mounted) return;

    if (mensaje == 'LIMITE') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Límite alcanzado'),
          content: const Text(
            'Has alcanzado el límite de reenvíos. Por favor verifica la dirección de correo que ingresaste.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    if (mensaje == 'LIMITE_ALCANZADO') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correo enviado'),
          content: const Text(
            'Correo enviado nuevamente. Has alcanzado el límite de reenvíos. Si no encuentras el correo, verifica tu dirección de correo electrónico.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                VerificacionCorreoControlador.resetearReenvios();
                Navigator.pop(context);
              },
              child: const Text('Intentar de nuevo'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensaje'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),
              Text(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.04),

              Text(
                'Te enviamos un correo al email asociado.\n\nAbre el enlace para activar tu cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size.width * 0.045),
              ),

              SizedBox(height: size.height * 0.06),

              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _verificarCorreo,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Verificar',
                          style: TextStyle(fontSize: size.width * 0.045),
                        ),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  SizedBox(
                    width: size.width * 0.38,
                    height: size.height * 0.06,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Registro',
                        style: TextStyle(fontSize: size.width * 0.04),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: size.width * 0.38,
                    height: size.height * 0.06,
                    child: OutlinedButton(
                      onPressed: _reenviarCorreo,
                      child: Text(
                        'Reenviar',
                        style: TextStyle(fontSize: size.width * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}