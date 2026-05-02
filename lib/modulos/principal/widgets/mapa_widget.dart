import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaWidget extends StatefulWidget {
  final double zoom;
  final LatLng? centroFijo;
  final List<LatLng>? rutaPuntos;
  final Color? rutaColor;

  const MapaWidget({
    super.key,
    this.zoom = 17,
    this.centroFijo,
    this.rutaPuntos,
    this.rutaColor,
  });

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget>
    with TickerProviderStateMixin {

  LatLng? _centroMapa;

  final MapController _mapController = MapController();

  bool _bloqueado = true;

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.centroFijo != null) {
      _centroMapa = widget.centroFijo;
    } else {
      _cargarCasaUsuario();
    }
  }

  Future<void> _cargarCasaUsuario() async {

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data();

    final lat = data?['lat'];
    final lng = data?['lng'];

    if (lat != null && lng != null) {

      if (!mounted) return;

      setState(() {
        _centroMapa = LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        );
      });
    }
  }

  void _centrarMapa() {

    if (_centroMapa == null) return;

    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: _centroMapa!.latitude,
    );

    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: _centroMapa!.longitude,
    );

    _controller?.dispose();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    _controller!.addListener(() {
      final lat = latTween.evaluate(animation);
      final lng = lngTween.evaluate(animation);

      _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
    });

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_centroMapa == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centroMapa!,
            initialZoom: widget.zoom,

            interactionOptions: InteractionOptions(
              flags: _bloqueado
                  ? InteractiveFlag.none
                  : InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.rutle',
            ),

            // Ruta del día (si fue asignada)
            if (widget.rutaPuntos != null && widget.rutaPuntos!.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.rutaPuntos!,
                    color: widget.rutaColor ?? const Color(0xFF1E88E5),
                    strokeWidth: 5,
                  ),
                ],
              ),
            if (widget.rutaPuntos != null && widget.rutaPuntos!.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.rutaPuntos!.first,
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.rutaColor ?? const Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),

            MarkerLayer(
              markers: [
                Marker(
                  point: _centroMapa!,
                  width: 44,
                  height: 44,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B78C9)
                          : const Color(0xFF00ACC1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        Positioned(
          top: 15,
          left: 15,
          child: FloatingActionButton(
            heroTag: "bloqueoMapa",
            mini: true,
            onPressed: () {
              setState(() {
                _bloqueado = !_bloqueado;
              });
            },
            child: Icon(
              _bloqueado
                  ? Icons.lock
                  : Icons.lock_open,
            ),
          ),
        ),

        Positioned(
          top: 15,
          right: 15,
          child: FloatingActionButton(
            heroTag: "centrarMapa",
            mini: true,
            onPressed: _centrarMapa,
            child: const Icon(Icons.my_location),
          ),
        ),

      ],
    );
  }
}