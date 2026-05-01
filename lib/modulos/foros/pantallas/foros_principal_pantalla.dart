import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/foros/controladores/foros_principal_controlador.dart';
import 'package:rutle_test/nucleo/widgets/boton_gradiente.dart';

class ForosPrincipalPantalla extends StatefulWidget {
  const ForosPrincipalPantalla({super.key});

  @override
  State<ForosPrincipalPantalla> createState() => _ForosPrincipalPantallaState();
}

class _ForosPrincipalPantallaState extends State<ForosPrincipalPantalla> {

  bool _mostrarAviso = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _mostrarMensajeExito() {
    setState(() => _mostrarAviso = true);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _mostrarAviso = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final controlador = ForosControlador();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                  : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Foros',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  botonGrande(context, "Mis foros", controlador.irMisForos),

                  const SizedBox(height: 20),

                  botonGrande(context, "Buscar foros", controlador.irBuscarForos),

                  const SizedBox(height: 20),

                  botonGrande(
                    context,
                    "Crear foro",
                    (ctx) async {
                      final resultado = await controlador.irCrearForo(ctx);
                      if (resultado == true) {
                        _mostrarMensajeExito();
                      }
                    },
                  ),

                ],
              ),
            ),

            Positioned(
              top: topPadding + size.height * 0.015,
              left: size.width * 0.08,
              right: size.width * 0.08,
              child: AnimatedOpacity(
                opacity: _mostrarAviso ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.016,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(size.height * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        size: size.height * 0.025,
                      ),
                      SizedBox(width: size.width * 0.03),
                      Text(
                        'Foro creado correctamente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget botonGrande(
    BuildContext context,
    String texto,
    Function(BuildContext) accion,
  ) {
    final size = MediaQuery.of(context).size;
    return BotonGradiente(
      texto: texto,
      ancho: double.infinity,
      alto: size.height * 0.095,
      borderRadius: 18,
      onPressed: () => accion(context),
    );
  }
}