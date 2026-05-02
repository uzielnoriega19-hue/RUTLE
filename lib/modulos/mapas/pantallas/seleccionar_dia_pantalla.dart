import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controladores/barra_semana_controlador.dart';

class SeleccionarDiaPantalla extends StatefulWidget {
  final DestinoSemana dia;
  const SeleccionarDiaPantalla({super.key, required this.dia});

  @override
  State<SeleccionarDiaPantalla> createState() =>
      _SeleccionarDiaPantallaState();
}

class _SeleccionarDiaPantallaState extends State<SeleccionarDiaPantalla> {
  String? _rutaSelDocId;    // selección en UI
  String? _rutaGuardadaDocId; // lo que está guardado en SharedPreferences
  Map<String, dynamic>? _rutaSelData;
  bool _guardando = false;

  String get _nombreDia {
    switch (widget.dia) {
      case DestinoSemana.lunes:      return 'Lunes';
      case DestinoSemana.martes:     return 'Martes';
      case DestinoSemana.miercoles:  return 'Miércoles';
      case DestinoSemana.jueves:     return 'Jueves';
      case DestinoSemana.viernes:    return 'Viernes';
      case DestinoSemana.sabado:     return 'Sábado';
      case DestinoSemana.domingo:    return 'Domingo';
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarSeleccionGuardada();
  }

  Future<void> _cargarSeleccionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final docId = prefs.getString(prefKeyRuta(widget.dia));
    if (docId == null || !mounted) return;

    setState(() => _rutaGuardadaDocId = docId);

    final doc = await FirebaseFirestore.instance
        .collection('rutas')
        .doc(docId)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _rutaSelDocId = docId;
        _rutaSelData = doc.data();
      });
    }
  }

  Future<void> _guardar() async {
    if (_rutaSelDocId == null) return;
    setState(() => _guardando = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKeyRuta(widget.dia), _rutaSelDocId!);

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _quitarRuta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefKeyRuta(widget.dia));
    if (mounted) Navigator.pop(context, true);
  }

  List<LatLng> _parsePoints(Map<String, dynamic> data) {
    final raw = data['puntos'] as List? ?? [];
    return raw
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final puntosPreview = _rutaSelData != null
        ? _parsePoints(_rutaSelData!)
        : <LatLng>[];
    final colorSel =
        _rutaSelDocId != null ? colorParaRuta(_rutaSelDocId!) : null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rutas — $_nombreDia',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ── Lista de rutas ─────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rutas')
                  .where('dias', arrayContains: _nombreDia)
                  .where('activa', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: cs.primary));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.route,
                            size: 56,
                            color: cs.onSurface.withValues(alpha: 0.25)),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          'No hay rutas activas para $_nombreDia',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    size.height * 0.02,
                    size.width * 0.05,
                    size.height * 0.02,
                  ),
                  children: [
                    // ── Tarjetas de ruta ────────────────────
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = data['nombre'] as String? ?? '—';
                      final diasRuta =
                          List<String>.from(data['dias'] as List? ?? []);
                      final color = colorParaRuta(doc.id);
                      final sel = _rutaSelDocId == doc.id;

                      return GestureDetector(
                        onTap: () => setState(() {
                          _rutaSelDocId = doc.id;
                          _rutaSelData = data;
                        }),
                        child: Container(
                          margin: EdgeInsets.only(bottom: size.height * 0.013),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: size.height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? color.withValues(alpha: 0.10)
                                : cs.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel
                                  ? color
                                  : cs.outline.withValues(alpha: 0.3),
                              width: sel ? 2 : 1.5,
                            ),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Círculo de color con palomita al seleccionar
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: sel
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 16)
                                    : null,
                              ),

                              SizedBox(width: size.width * 0.035),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ruta $nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.04,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    if (diasRuta.isNotEmpty)
                                      Text(
                                        diasRuta.join(' · '),
                                        style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.55),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),

                              Icon(Icons.chevron_right_rounded,
                                  color:
                                      cs.onSurface.withValues(alpha: 0.3)),
                            ],
                          ),
                        ),
                      );
                    }),

                    // ── Mini mapa del recorrido seleccionado ──
                    if (_rutaSelDocId != null &&
                        puntosPreview.length >= 2) ...[
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Recorrido de la ruta seleccionada',
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: size.height * 0.012),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: size.height * 0.28,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCameraFit: CameraFit.bounds(
                                bounds:
                                    LatLngBounds.fromPoints(puntosPreview),
                                padding: const EdgeInsets.all(40),
                              ),
                              initialZoom: 14,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.rutle',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: puntosPreview,
                                    color: colorSel!,
                                    strokeWidth: 4.5,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: puntosPreview.first,
                                    width: 18,
                                    height: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colorSel,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // ── Botones ────────────────────────────────────────
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.05,
              size.height * 0.018,
              size.width * 0.05,
              size.height * 0.03,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Quitar ruta" solo aparece si ya había una guardada
                if (_rutaGuardadaDocId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          size: 18),
                      label: const Text('Quitar ruta asignada'),
                      onPressed: _quitarRuta,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.014),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.012),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.016),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Opacity(
                        opacity: _rutaSelDocId != null ? 1.0 : 0.45,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.016),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ),
                              onPressed:
                                  _rutaSelDocId != null && !_guardando
                                      ? _guardar
                                      : null,
                              child: _guardando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
