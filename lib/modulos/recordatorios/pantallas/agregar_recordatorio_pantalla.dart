import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutle_test/compartido/toast.dart';
import 'package:rutle_test/modulos/mapas/controladores/barra_semana_controlador.dart';
import '../controladores/agregar_recordatorio_controlador.dart';

const _gdl = LatLng(20.6736, -103.3440);

class AgregarRecordatorioPantalla extends StatefulWidget {
  const AgregarRecordatorioPantalla({super.key});

  @override
  State<AgregarRecordatorioPantalla> createState() =>
      _AgregarRecordatorioPantallaState();
}

class _AgregarRecordatorioPantallaState
    extends State<AgregarRecordatorioPantalla> {
  final _controlador = AgregarRecordatorioControlador();
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();

  // Selección
  String? _diaSeleccionado;
  String? _rutaDocId;
  String? _rutaNombre;
  Color? _rutaColor;
  List<LatLng> _rutaPuntos = [];

  // Rutas de Firestore
  List<QueryDocumentSnapshot> _rutasFiltradas = [];
  bool _cargandoRutas = false;

  // Posición del usuario
  LatLng? _posUsuario;
  bool _mapaListo = false;
  bool _mapaLocked = true;

  // Formulario
  int? _minutosAntes;
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _guardando = false;

  static const _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const _tiempos = [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    _cargarPosUsuario();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // ─── Carga la posición del usuario desde Firestore ────────────

  Future<void> _cargarPosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final lat = doc.data()?['lat'];
    final lng = doc.data()?['lng'];

    if (lat != null && lng != null && mounted) {
      setState(() {
        _posUsuario = LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        );
      });
      _ajustarCamara();
    }
  }

  // ─── Ajusta la cámara para mostrar usuario + ruta ─────────────

  void _ajustarCamara() {
    if (!_mapaListo || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapaListo) return;
      final puntos = <LatLng>[
        ?_posUsuario,
        ..._rutaPuntos,
      ];
      try {
        if (puntos.length >= 2) {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(puntos),
              padding: const EdgeInsets.all(60),
            ),
          );
        } else if (_posUsuario != null) {
          _mapController.move(_posUsuario!, 15.5);
        }
      } catch (_) {}
    });
  }

  // ─── Al cambiar día: carga rutas activas filtradas ───────────

  Future<void> _onDiaChanged(String? dia) async {
    if (dia == null) return;
    setState(() {
      _diaSeleccionado = dia;
      _rutaDocId = null;
      _rutaNombre = null;
      _rutaColor = null;
      _rutaPuntos = [];
      _rutasFiltradas = [];
      _cargandoRutas = true;
    });

    final snap = await FirebaseFirestore.instance
        .collection('rutas')
        .where('dias', arrayContains: dia)
        .where('activa', isEqualTo: true)
        .get();

    if (mounted) {
      setState(() {
        _rutasFiltradas = snap.docs;
        _cargandoRutas = false;
      });
    }
  }

  // ─── Al tocar una tarjeta de ruta ────────────────────────────

  void _seleccionarRuta(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nombre = data['nombre'] as String? ?? '—';
    final raw = data['puntos'] as List? ?? [];
    final puntos = raw
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ))
        .toList();

    final mismaRuta = _rutaDocId == doc.id;
    setState(() {
      if (mismaRuta) {
        // Toca la misma → deseleccionar
        _rutaDocId = null;
        _rutaNombre = null;
        _rutaColor = null;
        _rutaPuntos = [];
      } else {
        _rutaDocId = doc.id;
        _rutaNombre = nombre;
        _rutaColor = colorParaRuta(doc.id);
        _rutaPuntos = puntos;
      }
    });
    _ajustarCamara();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final lineaColor =
        isDark ? const Color(0xFF4FC3F7) : const Color(0xFF00ACC1);

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
        title: const Text('Agregar recordatorio',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.025),

                  // ── Día ───────────────────────────────────────
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona el día',
                      border: OutlineInputBorder(),
                    ),
                    value: _diaSeleccionado,
                    items: _dias
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: _onDiaChanged,
                    validator: (v) => v == null ? 'Selecciona un día' : null,
                  ),

                  // ── Rutas filtradas por día ────────────────────
                  if (_diaSeleccionado != null) ...[
                    SizedBox(height: size.height * 0.02),

                    if (_cargandoRutas)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: cs.primary)),
                      )
                    else if (_rutasFiltradas.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01),
                        child: Text(
                          'No hay rutas activas para $_diaSeleccionado.',
                          style: TextStyle(color: cs.error),
                        ),
                      )
                    else ...[
                      Text(
                        'Selecciona una ruta',
                        style: TextStyle(
                          fontSize: size.width * 0.037,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),

                      // Tarjetas de ruta (lista desplegable)
                      ..._rutasFiltradas.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final nombre = data['nombre'] as String? ?? '—';
                        final diasRuta = List<String>.from(
                            data['dias'] as List? ?? []);
                        final color = colorParaRuta(doc.id);
                        final sel = _rutaDocId == doc.id;

                        return GestureDetector(
                          onTap: () => _seleccionarRuta(doc),
                          child: Container(
                            margin: EdgeInsets.only(
                                bottom: size.height * 0.012),
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.014,
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
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: sel
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 15)
                                      : null,
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ruta $nombre',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * 0.038,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      if (diasRuta.isNotEmpty)
                                        Text(
                                          diasRuta.join(' · '),
                                          style: TextStyle(
                                            fontSize: size.width * 0.029,
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
                                    color: cs.onSurface
                                        .withValues(alpha: 0.3)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],

                  SizedBox(height: size.height * 0.025),

                  // ── Mapa: usuario + ruta seleccionada ─────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                    child: SizedBox(
                      height: size.height * 0.35,
                      child: Stack(
                        children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _posUsuario ?? _gdl,
                          initialZoom: 15.0,
                          interactionOptions: InteractionOptions(
                            flags: _mapaLocked
                                ? InteractiveFlag.none
                                : InteractiveFlag.all,
                          ),
                          onMapReady: () {
                            setState(() => _mapaListo = true);
                            _ajustarCamara();
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.rutle',
                          ),

                          // Polyline de la ruta seleccionada
                          if (_rutaPuntos.length >= 2)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _rutaPuntos,
                                  color: _rutaColor ?? lineaColor,
                                  strokeWidth: 5,
                                ),
                              ],
                            ),

                          MarkerLayer(
                            markers: [
                              // Inicio de ruta
                              if (_rutaPuntos.isNotEmpty)
                                Marker(
                                  point: _rutaPuntos.first,
                                  width: 18,
                                  height: 18,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _rutaColor ?? lineaColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2.5),
                                    ),
                                  ),
                                ),

                              // Ubicación del usuario
                              if (_posUsuario != null)
                                Marker(
                                  point: _posUsuario!,
                                  width: 44,
                                  height: 44,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1B78C9)
                                              : const Color(0xFF00ACC1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white,
                                              width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.3),
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
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      // Botón candado
                      Positioned(
                        top: 10,
                        left: 10,
                        child: FloatingActionButton(
                          heroTag: "candadoRecordatorio",
                          mini: true,
                          onPressed: () =>
                              setState(() => _mapaLocked = !_mapaLocked),
                          child: Icon(
                              _mapaLocked ? Icons.lock : Icons.lock_open),
                        ),
                      ),

                      // Botón recentrar
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FloatingActionButton(
                          heroTag: "centrarRecordatorio",
                          mini: true,
                          onPressed: _ajustarCamara,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Minutos antes ──────────────────────────────
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Notificación minutos antes',
                      border: OutlineInputBorder(),
                    ),
                    value: _minutosAntes,
                    items: _tiempos
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text('$t minutos')))
                        .toList(),
                    onChanged: (v) => setState(() => _minutosAntes = v),
                    validator: (v) =>
                        v == null ? 'Selecciona el tiempo' : null,
                  ),

                  SizedBox(height: size.height * 0.02),

                  // ── Título ─────────────────────────────────────
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título del recordatorio',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Este campo es obligatorio'
                        : null,
                  ),

                  SizedBox(height: size.height * 0.02),

                  // ── Descripción ────────────────────────────────
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── Botones ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
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
                                    vertical: size.height * 0.018),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ),
                              onPressed: _guardando
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      if (_rutaDocId == null) {
                                        mostrarError(context,
                                            'Selecciona una ruta primero');
                                        return;
                                      }
                                      setState(() => _guardando = true);
                                      try {
                                        await _controlador
                                            .guardarRecordatorio(
                                          titulo: _tituloController.text,
                                          descripcion:
                                              _descripcionController.text,
                                          minutosAntes: _minutosAntes!,
                                          dia: _diaSeleccionado!,
                                          ruta: 'Ruta $_rutaNombre',
                                        );
                                        if (context.mounted) {
                                          mostrarExito(context,
                                              '¡Recordatorio creado correctamente!');
                                          Navigator.pop(context, true);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          mostrarError(context,
                                              'Error al guardar el recordatorio');
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(
                                              () => _guardando = false);
                                        }
                                      }
                                    },
                              child: _guardando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
