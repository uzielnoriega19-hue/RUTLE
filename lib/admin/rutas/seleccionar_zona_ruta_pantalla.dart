import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum _Estado { esperandoInicio, cargando, trazando }

const _gdl = LatLng(20.6736, -103.3440);

class SeleccionarZonaRutaPantalla extends StatefulWidget {
  const SeleccionarZonaRutaPantalla({super.key});

  @override
  State<SeleccionarZonaRutaPantalla> createState() =>
      _SeleccionarZonaRutaPantallaState();
}

class _SeleccionarZonaRutaPantallaState
    extends State<SeleccionarZonaRutaPantalla> {
  _Estado _estado = _Estado.esperandoInicio;

  final List<LatLng> _puntos = [];
  // Cuántos puntos añadió cada segmento ORS (para deshacer uno a uno)
  final List<int> _segmentos = [];

  String? _error;
  final MapController _mapController = MapController();

  // ─── API key ─────────────────────────────────────────────────
  static const String _orsApiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImU1ZTIyNDI2ODE3NjRkN2FiYjkwNGEyMjFmYjI5Mzc2IiwiaCI6Im11cm11cjY0In0=';

  // ─── ORS: ruta entre dos puntos ──────────────────────────────

  Future<List<LatLng>?> _routeORS(LatLng from, LatLng to) async {
    try {
      final res = await http
          .post(
            Uri.parse(
              'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
            ),
            headers: {
              'Authorization': _orsApiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'coordinates': [
                [from.longitude, from.latitude],
                [to.longitude, to.latitude],
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final coords =
            data['features'][0]['geometry']['coordinates'] as List;
        return coords
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  // ─── Toque en el mapa ────────────────────────────────────────

  Future<void> _onMapTap(TapPosition _, LatLng tap) async {
    if (_estado == _Estado.cargando) return;

    // Primer toque → marca el inicio sin llamar a ORS
    if (_estado == _Estado.esperandoInicio) {
      setState(() {
        _puntos
          ..clear()
          ..add(tap);
        _segmentos
          ..clear()
          ..add(1);
        _estado = _Estado.trazando;
        _error = null;
      });
      _mapController.move(tap, _mapController.camera.zoom);
      return;
    }

    // Toques siguientes → ORS desde el último punto al nuevo
    final from = _puntos.last;
    setState(() {
      _estado = _Estado.cargando;
      _error = null;
    });

    final ruta = await _routeORS(from, tap);
    if (!mounted) return;

    if (ruta == null) {
      setState(() {
        _estado = _Estado.trazando;
        _error = 'No se pudo trazar ese segmento. Toca otro punto.';
      });
      return;
    }

    final nuevos = ruta.skip(1).toList(); // omitir el punto de origen duplicado
    if (nuevos.isEmpty) {
      setState(() {
        _estado = _Estado.trazando;
        _error = 'Punto muy cercano. Toca un poco más lejos.';
      });
      return;
    }

    setState(() {
      _puntos.addAll(nuevos);
      _segmentos.add(nuevos.length);
      _estado = _Estado.trazando;
    });
    _mapController.move(_puntos.last, _mapController.camera.zoom);
  }

  // ─── Deshacer último segmento ────────────────────────────────

  void _deshacer() {
    if (_segmentos.length <= 1 || _estado == _Estado.cargando) return;

    final count = _segmentos.removeLast();
    setState(() {
      _puntos.removeRange(_puntos.length - count, _puntos.length);
      _error = null;
      if (_segmentos.length == 1) _estado = _Estado.esperandoInicio;
    });

    if (_puntos.isNotEmpty) {
      _mapController.move(_puntos.last, _mapController.camera.zoom);
    }
  }

  void _reiniciar() {
    setState(() {
      _puntos.clear();
      _segmentos.clear();
      _estado = _Estado.esperandoInicio;
      _error = null;
    });
  }

  void _listo() => Navigator.pop(context, List<LatLng>.from(_puntos));

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final lineaColor =
        isDark ? const Color(0xFF4FC3F7) : const Color(0xFF00ACC1);

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _gdl,
              initialZoom: 15.5,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rutle',
              ),
              if (_puntos.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _puntos,
                      color: lineaColor,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_puntos.isNotEmpty)
                    Marker(
                      point: _puntos.first,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: lineaColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  if (_puntos.length > 1)
                    Marker(
                      point: _puntos.last,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: lineaColor, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Spinner sobre el mapa ──────────────────────────────
          if (_estado == _Estado.cargando)
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text('Trazando por calles...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

          // ── AppBar ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Trazar Ruta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Panel inferior ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPanel(context, gradColors, height, width),
          ),
        ],
      ),
    );
  }

  // ─── Panel inferior ───────────────────────────────────────────

  Widget _buildPanel(BuildContext context, List<Color> gradColors,
      double height, double width) {
    final cs = Theme.of(context).colorScheme;

    final deco = BoxDecoration(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );

    final tirador = Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cs.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    switch (_estado) {
      // ── Esperando primer toque ─────────────────────────────
      case _Estado.esperandoInicio:
        return Container(
          decoration: deco,
          padding: EdgeInsets.fromLTRB(
              width * 0.06, height * 0.025, width * 0.06, height * 0.045),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tirador,
              Icon(Icons.touch_app_rounded, size: 42, color: cs.primary),
              SizedBox(height: height * 0.012),
              Text(
                'Toca el mapa para marcar\nel inicio de la ruta',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface),
              ),
              SizedBox(height: height * 0.018),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: height * 0.015),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        );

      // ── Cargando ORS ──────────────────────────────────────
      case _Estado.cargando:
        return Container(
          decoration: deco,
          padding: EdgeInsets.fromLTRB(
              width * 0.06, height * 0.025, width * 0.06, height * 0.045),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tirador,
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: cs.primary),
              ),
              SizedBox(height: height * 0.014),
              Text(
                'Trazando por calles...',
                style: TextStyle(
                    fontSize: width * 0.038, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        );

      // ── Trazando punto a punto ─────────────────────────────
      case _Estado.trazando:
        final canUndo = _segmentos.length > 1;
        final canListo = _puntos.length >= 2;

        return Container(
          decoration: deco,
          padding: EdgeInsets.fromLTRB(
              width * 0.06, height * 0.025, width * 0.06, height * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tirador,

              if (_error != null) ...[
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: cs.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              fontSize: width * 0.034, color: cs.error)),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.012),
              ],

              Text(
                'Toca el siguiente punto en el mapa\npara continuar la ruta',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface),
              ),
              SizedBox(height: height * 0.018),

              Row(
                children: [
                  // Regresar
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.undo_rounded,
                          size: 16,
                          color: canUndo
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.3)),
                      label: Text('Regresar',
                          style: TextStyle(
                              color: canUndo
                                  ? null
                                  : cs.onSurface.withValues(alpha: 0.3))),
                      onPressed: canUndo ? _deshacer : null,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.014),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.02),

                  // Cancelar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reiniciar,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.014),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reiniciar'),
                    ),
                  ),
                  SizedBox(width: width * 0.02),

                  // Listo → devuelve puntos a CrearRutaPantalla
                  Expanded(
                    child: Opacity(
                      opacity: canListo ? 1.0 : 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                                  vertical: height * 0.014),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            onPressed: canListo ? _listo : null,
                            child: const Text('Listo'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
