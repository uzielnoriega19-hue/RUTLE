import 'package:flutter/material.dart';

class DiaItem extends StatelessWidget {
  final String dia;
  final bool seleccionado;

  const DiaItem({
    super.key,
    required this.dia,
    this.seleccionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.11,
      height: size.width * 0.11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Seleccionado (hoy): círculo blanco sólido
        // No seleccionado: blanco translúcido sobre el fondo azul
        // Siempre blanco — la barra es siempre un gradiente colorido
        color: seleccionado
            ? Colors.white
            : Colors.white.withValues(alpha: 0.20),
        boxShadow: seleccionado
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          dia,
          style: TextStyle(
            fontSize: size.width * 0.042,
            fontWeight: FontWeight.w700,
            // Hoy: texto azul oscuro sobre círculo blanco (contraste alto)
            // Resto: blanco sobre fondo translúcido
            color: seleccionado
                ? const Color(0xFF081528)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}