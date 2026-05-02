import 'package:flutter/material.dart';
import 'crear_ruta_pantalla.dart';
import 'ver_rutas_pantalla.dart';

class RutaPrincipalPantalla extends StatelessWidget {
  const RutaPrincipalPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('Rutas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          width * 0.08,
          height * 0.2,
          width * 0.08,
          height * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¿Cómo quieres comenzar\na crear tu ruta?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: height * 0.05),

            // ── Comenzar desde cero ──────────────────────
            _BotonGradiente(
              texto: 'Comenzar desde cero',
              gradientColors: gradientColors,
              height: height,
              width: width,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CrearRutaPantalla()),
              ),
            ),

            SizedBox(height: height * 0.02),

            // ── Usar ruta existente ───────────────────────
            _BotonGradiente(
              texto: 'Usar ruta existente',
              gradientColors: gradientColors,
              height: height,
              width: width,
              onPressed: () {},
            ),

            SizedBox(height: height * 0.02),

            // ── Ver rutas ────────────────────────────────
            _BotonGradiente(
              texto: 'Ver rutas',
              gradientColors: gradientColors,
              height: height,
              width: width,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VerRutasPantalla()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonGradiente extends StatelessWidget {
  final String texto;
  final List<Color> gradientColors;
  final double height;
  final double width;
  final VoidCallback onPressed;

  const _BotonGradiente({
    required this.texto,
    required this.gradientColors,
    required this.height,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, height * 0.065),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
          ),
          onPressed: onPressed,
          child: Text(texto, style: TextStyle(fontSize: width * 0.042)),
        ),
      ),
    );
  }
}
