import 'package:flutter/material.dart';
import 'crear_ruta_pantalla.dart';

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

      // 🔥 YA NO HAY CENTER
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          width * 0.08,
          height * 0.2, // espacio arriba
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

            // ───── BOTÓN 1 ─────
            ClipRRect(
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
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CrearRutaPantalla(),
                    ),
                  ),
                  child: Text(
                    'Comenzar desde cero',
                    style: TextStyle(fontSize: width * 0.042),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.02),

            // ───── BOTÓN 2 ─────
            ClipRRect(
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
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    // placeholder
                  },
                  child: Text(
                    'Usar ruta existente',
                    style: TextStyle(fontSize: width * 0.042),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.02),

            // ───── BOTÓN 3 ─────
            ClipRRect(
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
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    // placeholder
                  },
                  child: Text(
                    'Ver rutas',
                    style: TextStyle(fontSize: width * 0.042),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}