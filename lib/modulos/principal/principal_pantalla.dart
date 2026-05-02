import 'dart:ui' show ImageFilter;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutle_test/modulos/mapas/controladores/barra_semana_controlador.dart';
import 'package:rutle_test/modulos/mapas/pantallas/barra_semana_pantalla.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/dia_item.dart';
import 'widgets/mapa_widget.dart';

class PrincipalPantalla extends StatefulWidget {
  const PrincipalPantalla({super.key});

  @override
  State<PrincipalPantalla> createState() => _PrincipalPantallaState();
}

class _PrincipalPantallaState extends State<PrincipalPantalla> {
  // dayIndex (0=Lun … 6=Dom) → docId de la ruta asignada
  final Map<int, String> _rutasPorDia = {};
  List<LatLng> _puntosHoy = [];
  Color? _colorHoy;

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  Future<void> _cargarRutas() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, String> nuevas = {};

    for (int i = 0; i < 7; i++) {
      final docId = prefs.getString(prefKeyRuta(DestinoSemana.values[i]));
      if (docId != null) nuevas[i] = docId;
    }

    // Cargar puntos de la ruta de hoy desde Firestore
    List<LatLng> puntosHoy = [];
    Color? colorHoy;

    final hoyIdx = DateTime.now().weekday - 1; // 0=Lun…6=Dom
    final hoyDocId = nuevas[hoyIdx];

    if (hoyDocId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('rutas')
            .doc(hoyDocId)
            .get();
        if (doc.exists) {
          final raw = doc.data()?['puntos'] as List? ?? [];
          puntosHoy = raw
              .map((p) => LatLng(
                    (p['lat'] as num).toDouble(),
                    (p['lng'] as num).toDouble(),
                  ))
              .toList();
          colorHoy = colorParaRuta(hoyDocId);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _rutasPorDia
          ..clear()
          ..addAll(nuevas);
        _puntosHoy = puntosHoy;
        _colorHoy = colorHoy;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hoyIdx = DateTime.now().weekday - 1;
    const diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

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

    // ── Contenido de la barra semana ──────────────────────────
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.02, bottom: size.height * 0.012),
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

        // Círculos de día
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            return DiaItem(dia: diasSemana[i], seleccionado: i == hoyIdx);
          }),
        ),

        SizedBox(height: size.height * 0.015),

        // Cuadros con palomita de color cuando hay ruta asignada
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final esHoy = i == hoyIdx;
            final docId = _rutasPorDia[i];
            final tieneRuta = docId != null;

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
              child: tieneRuta
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: size.width * 0.052,
                    )
                  : null,
            );
          }),
        ),
      ],
    );

    // ── Barra semana con estilos oscuro / claro ───────────────
    final barraWidget = isDark
        ? Container(
            decoration:
                BoxDecoration(borderRadius: radius, boxShadow: [shadow]),
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
                        const Color(0xFF1C3F71).withValues(alpha: 0.82),
                        const Color(0xFF1B78C9).withValues(alpha: 0.82),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: contenido,
                ),
              ),
            ),
          )
        : Container(
            padding: pad,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [shadow],
            ),
            child: contenido,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          'RUTLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: size.height * 0.03),

              // Toca la barra → BarraSemanaPantalla → al regresar recarga
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BarraSemanaPantalla()),
                  );
                  _cargarRutas();
                },
                child: barraWidget,
              ),

              SizedBox(height: size.height * 0.04),

              // Mapa con la ruta del día si está asignada
              Container(
                height: size.height * 0.50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.04),
                ),
                clipBehavior: Clip.hardEdge,
                child: MapaWidget(
                  zoom: 15.5,
                  rutaPuntos: _puntosHoy.length >= 2 ? _puntosHoy : null,
                  rutaColor: _colorHoy,
                ),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
