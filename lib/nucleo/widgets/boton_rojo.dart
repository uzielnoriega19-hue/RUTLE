import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Botón de acción destructiva con degradado rojo.
/// Claro: rojo brillante → rojo oscuro sólido.
/// Oscuro: rojo muy oscuro semitransparente + blur.
class BotonRojo extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final Widget? iconoWidget;
  final double? ancho;
  final double? alto;
  final double borderRadius;

  const BotonRojo({
    super.key,
    required this.texto,
    this.onPressed,
    this.iconoWidget,
    this.ancho,
    this.alto,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final radio = BorderRadius.circular(borderRadius);

    final gradiente = isDark
        ? LinearGradient(
            colors: [
              const Color(0xFF5C0A0A).withValues(alpha: 0.85),
              const Color(0xFFD32F2F).withValues(alpha: 0.85),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFC62828)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );

    final fondo = Container(
      width: ancho,
      height: alto,
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.018,
        horizontal: size.width * 0.04,
      ),
      decoration: BoxDecoration(borderRadius: radio, gradient: gradiente),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconoWidget != null) ...[
            iconoWidget!,
            SizedBox(width: size.width * 0.02),
          ],
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: radio,
      child: isDark
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  splashColor: Colors.white.withValues(alpha: 0.15),
                  highlightColor: Colors.white.withValues(alpha: 0.10),
                  child: fondo,
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withValues(alpha: 0.20),
                highlightColor: Colors.white.withValues(alpha: 0.12),
                child: fondo,
              ),
            ),
    );
  }
}
