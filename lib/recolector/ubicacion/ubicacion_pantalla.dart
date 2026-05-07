import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const _gdl = LatLng(20.6736, -103.3440);

class UbicacionRecolectorPantalla extends StatefulWidget {
  const UbicacionRecolectorPantalla({super.key});

  @override
  State<UbicacionRecolectorPantalla> createState() =>
      _UbicacionRecolectorPantallaState();
}

class _UbicacionRecolectorPantallaState
    extends State<UbicacionRecolectorPantalla> {
  final _mapController = MapController();

  bool _enviando = false;
  bool _mapaListo = false;
  bool _permisoDenegado = false;
  LatLng? _posicion;
  DateTime? _ultimaActualizacion;
  StreamSubscription<Position>? _streamPos;

  @override
  void initState() {
    super.initState();
    _obtenerPosicionInicial();
  }

  @override
  void dispose() {
    _streamPos?.cancel();
    super.dispose();
  }

  // ─── Permisos ─────────────────────────────────────────────────────

  Future<bool> _verificarPermiso() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _permisoDenegado = true);
      return false;
    }
    return true;
  }

  // ─── Posición inicial ─────────────────────────────────────────────

  Future<void> _obtenerPosicionInicial() async {
    final ok = await _verificarPermiso();
    if (!ok || !mounted) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() => _posicion = LatLng(pos.latitude, pos.longitude));
      _moverCamara(_posicion!);
    } catch (_) {}
  }

  void _moverCamara(LatLng punto) {
    if (!_mapaListo) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapaListo) return;
      try {
        _mapController.move(punto, _mapController.camera.zoom < 14 ? 16 : _mapController.camera.zoom);
      } catch (_) {}
    });
  }

  // ─── Toggle envío ─────────────────────────────────────────────────

  Future<void> _toggleEnvio() async {
    if (_enviando) {
      await _streamPos?.cancel();
      _streamPos = null;
      setState(() {
        _enviando = false;
        _ultimaActualizacion = null;
      });
      return;
    }

    final ok = await _verificarPermiso();
    if (!ok) return;

    setState(() => _enviando = true);

    _streamPos = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (Position pos) async {
        final punto = LatLng(pos.latitude, pos.longitude);
        if (!mounted) return;
        setState(() {
          _posicion = punto;
          _ultimaActualizacion = DateTime.now();
        });
        _moverCamara(punto);
        await _guardarEnFirestore(pos);
      },
      onError: (_) {
        if (mounted) setState(() => _enviando = false);
      },
    );
  }

  Future<void> _guardarEnFirestore(Position pos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'ultimaUbicacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // ─── UI ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradColors = isDark
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
              colors: gradColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Mi Ubicación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _permisoDenegado
          ? _PantallaPermisoDenegado(onReintentar: _obtenerPosicionInicial)
          : Column(
              children: [
                // ── Mapa ──────────────────────────────────────────
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _posicion ?? _gdl,
                          initialZoom: 16,
                          onMapReady: () {
                            _mapaListo = true;
                            if (_posicion != null) _moverCamara(_posicion!);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.rutle',
                          ),
                          if (_posicion != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _posicion!,
                                  width: 52,
                                  height: 52,
                                  child: _MarcadorRecolector(
                                    enviando: _enviando,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      // Indicador de carga si no hay posición
                      if (_posicion == null)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),

                // ── Panel inferior ────────────────────────────────
                _PanelEnvio(
                  enviando: _enviando,
                  ultimaActualizacion: _ultimaActualizacion,
                  gradColors: gradColors,
                  isDark: isDark,
                  size: size,
                  onToggle: _toggleEnvio,
                ),
              ],
            ),
    );
  }
}

// ─── Marcador del recolector ───────────────────────────────────────────────

class _MarcadorRecolector extends StatelessWidget {
  final bool enviando;
  final bool isDark;
  const _MarcadorRecolector({required this.enviando, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = enviando
        ? Colors.green.shade600
        : (isDark ? const Color(0xFF1B78C9) : const Color(0xFF00ACC1));

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// ─── Panel de envío ───────────────────────────────────────────────────────

class _PanelEnvio extends StatelessWidget {
  final bool enviando;
  final DateTime? ultimaActualizacion;
  final List<Color> gradColors;
  final bool isDark;
  final Size size;
  final VoidCallback onToggle;

  const _PanelEnvio({
    required this.enviando,
    required this.ultimaActualizacion,
    required this.gradColors,
    required this.isDark,
    required this.size,
    required this.onToggle,
  });

  String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        size.width * 0.06,
        size.height * 0.022,
        size.width * 0.06,
        size.height * 0.034,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill handle
          Container(
            width: 36,
            height: 4,
            margin: EdgeInsets.only(bottom: size.height * 0.018),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: enviando ? Colors.green : cs.onSurface.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: enviando
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
              ),
              SizedBox(width: size.width * 0.025),
              Text(
                enviando ? 'Enviando ubicación' : 'Ubicación detenida',
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: enviando ? Colors.green.shade700 : cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),

          if (enviando && ultimaActualizacion != null) ...[
            SizedBox(height: size.height * 0.006),
            Text(
              'Última actualización: ${_formatHora(ultimaActualizacion!)}',
              style: TextStyle(
                fontSize: size.width * 0.03,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],

          SizedBox(height: size.height * 0.022),

          // Botón
          SizedBox(
            width: double.infinity,
            child: enviando
                ? ElevatedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text(
                      'Detener envío',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onToggle,
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text(
                          'Compartir ubicación',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.018),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Pantalla de permiso denegado ─────────────────────────────────────────

class _PantallaPermisoDenegado extends StatelessWidget {
  final VoidCallback onReintentar;
  const _PantallaPermisoDenegado({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                size: 64, color: cs.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Sin acceso a ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Activa el permiso de ubicación en la configuración del dispositivo para poder compartir tu posición.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
