import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/mapas/pantallas/barra_semana_pantalla.dart';
import 'widgets/dia_item.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';

class PrincipalPantalla extends StatelessWidget {
  const PrincipalPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diaHoy = DateTime.now().weekday - 1;
    final diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final radius = BorderRadius.circular(size.width * 0.05);

    final pad = EdgeInsets.symmetric(
      vertical: size.height * 0.025,
      horizontal: size.width * 0.04,
    );

    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
      blurRadius: isDark ? 30 : 18,
      offset: const Offset(0, 8),
    );

    // ================= CONTENIDO =================
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.02,
            bottom: size.height * 0.012,
          ),
          child: Text(
            'Semana de recolección',
            style: TextStyle(
              color: Colors.white.withValues(alpha: isDark ? 0.85 : 1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            return DiaItem(
              dia: diasSemana[i],
              seleccionado: i == diaHoy,
            );
          }),
        ),

        SizedBox(height: size.height * 0.015),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final esHoy = i == diaHoy;

            return Container(
              width: size.width * 0.08,
              height: size.width * 0.08,
              decoration: BoxDecoration(
                border: Border.all(
                  color: esHoy
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  width: esHoy ? 2.0 : 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
                color: esHoy
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            );
          }),
        ),
      ],
    );

    // ================= BARRA =================
    final barraWidget = isDark
        ? Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [shadow],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Container(
                  padding: pad,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 28, 63, 113).withValues(alpha: 0.82),
                        Color.fromARGB(255, 27, 120, 201).withValues(alpha: 0.82),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),

                  // ✅ AQUÍ solo queda el contenido (sin capas blancas)
                  child: contenido,
                ),
              ),
            ),
          )

        // ☀️ MODO CLARO
        : Container(
            padding: pad,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00ACC1),
                  Color(0xFF6FD3FF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [shadow],
            ),
            child: contenido,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: size.height * 0.12),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BarraSemanaPantalla(),
                    ),
                  );
                },
                child: barraWidget,
              ),

              SizedBox(height: size.height * 0.04),

              Container(
                height: size.height * 0.50,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(size.width * 0.04),
                ),
                clipBehavior: Clip.hardEdge,
                child: const MapaWidget(zoom: 15.5),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}