import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _diasOrden = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

class InfoRutaPantalla extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const InfoRutaPantalla({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<InfoRutaPantalla> createState() => _InfoRutaPantallaState();
}

class _InfoRutaPantallaState extends State<InfoRutaPantalla> {
  // Copia local mutable del documento
  late Map<String, dynamic> _data;

  bool _editando = false;
  late bool _activaEdit;
  late Set<String> _diasEdit;
  bool _guardando = false;

  final MapController _mapController = MapController();
  bool _mapaLocked = true;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data);
    _iniciarEstadoEdicion();
  }

  void _iniciarEstadoEdicion() {
    _activaEdit = _data['activa'] as bool? ?? true;
    _diasEdit = Set<String>.from(_data['dias'] as List? ?? []);
  }

  // ─── Helpers ─────────────────────────────────────────────────

  List<LatLng> get _puntos {
    final raw = _data['puntos'] as List? ?? [];
    return raw
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ))
        .toList();
  }

  String _formatearFecha(dynamic ts) {
    if (ts == null || ts is! Timestamp) return '—';
    final dt = ts.toDate();
    const meses = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${meses[dt.month]} ${dt.year}';
  }

  String _truncarUid(String? uid) {
    if (uid == null || uid.isEmpty) return '—';
    return uid.length > 12 ? '${uid.substring(0, 12)}…' : uid;
  }

  List<String> get _diasOrdenados =>
      _diasOrden.where((d) => _diasEdit.contains(d)).toList();

  // ─── Eliminar ────────────────────────────────────────────────

  Future<void> _eliminar() async {
    final nombre = _data['nombre'] as String? ?? '';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ruta'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la ruta "$nombre"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('rutas')
          .doc(widget.docId)
          .delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // ─── Modificar ───────────────────────────────────────────────

  void _abrirEdicion() {
    _iniciarEstadoEdicion();
    setState(() => _editando = true);
  }

  void _cancelarEdicion() => setState(() => _editando = false);

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);

    final diasOrdenados = _diasOrdenados;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ahora = Timestamp.now();

    try {
      await FirebaseFirestore.instance
          .collection('rutas')
          .doc(widget.docId)
          .update({
        'activa': _activaEdit,
        'dias': diasOrdenados,
        'ultimaModificacion': FieldValue.serverTimestamp(),
        'modificadoPor': uid,
      });

      setState(() {
        _data['activa'] = _activaEdit;
        _data['dias'] = diasOrdenados;
        _data['modificadoPor'] = uid;
        _data['ultimaModificacion'] = ahora;
        _editando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final gradientColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final lineaColor =
        isDark ? const Color(0xFF4FC3F7) : const Color(0xFF00ACC1);

    final nombre = _data['nombre'] as String? ?? '—';
    final activa = _data['activa'] as bool? ?? true;
    final totalPuntos = _data['totalPuntos'] as int? ?? 0;
    final dias = List<String>.from(_data['dias'] as List? ?? []);
    final creadoEn = _data['creadoEn'];
    final creadoPor = _data['creadoPor'] as String?;
    final ultimaMod = _data['ultimaModificacion'];
    final modificadoPor = _data['modificadoPor'] as String?;
    final puntos = _puntos;
    final bounds =
        puntos.length >= 2 ? LatLngBounds.fromPoints(puntos) : null;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              _guardando ? null : () => Navigator.pop(context),
        ),
        title: Text(
          _editando ? 'Modificar Ruta $nombre' : 'Ruta $nombre',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ── Contenido ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Información general (siempre visible) ─────
                  _Seccion(
                    titulo: 'Información general',
                    child: Column(
                      children: [
                        _InfoFila(
                          icono: Icons.label_rounded,
                          etiqueta: 'Nombre',
                          valor: 'Ruta $nombre',
                          color: lineaColor,
                        ),
                        _InfoFila(
                          icono: activa
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          etiqueta: 'Estado',
                          valor: activa ? 'Activa' : 'Inactiva',
                          color: activa ? Colors.green : Colors.grey,
                        ),
                        _InfoFila(
                          icono: Icons.location_on_rounded,
                          etiqueta: 'Puntos totales',
                          valor: '$totalPuntos puntos',
                          color: lineaColor,
                        ),
                        _InfoFila(
                          icono: Icons.calendar_today_rounded,
                          etiqueta: 'Creado el',
                          valor: _formatearFecha(creadoEn),
                          color: lineaColor,
                        ),
                        _InfoFila(
                          icono: Icons.person_rounded,
                          etiqueta: 'Creado por',
                          valor: _truncarUid(creadoPor),
                          color: lineaColor,
                        ),
                        if (ultimaMod != null) ...[
                          _InfoFila(
                            icono: Icons.edit_calendar_rounded,
                            etiqueta: 'Última modificación',
                            valor: _formatearFecha(ultimaMod),
                            color: cs.tertiary,
                          ),
                          _InfoFila(
                            icono: Icons.manage_accounts_rounded,
                            etiqueta: 'Modificado por',
                            valor: _truncarUid(modificadoPor),
                            color: cs.tertiary,
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.025),

                  // ── Días: vista o edición ─────────────────────
                  _editando
                      ? _SeccionEdicion(
                          titulo: 'Días de operación',
                          child: Wrap(
                            spacing: width * 0.02,
                            runSpacing: height * 0.01,
                            children: _diasOrden.map((dia) {
                              final sel = _diasEdit.contains(dia);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  sel
                                      ? _diasEdit.remove(dia)
                                      : _diasEdit.add(dia);
                                }),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04,
                                      vertical: height * 0.011),
                                  decoration: BoxDecoration(
                                    gradient: sel
                                        ? LinearGradient(
                                            colors: gradientColors,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )
                                        : null,
                                    border: Border.all(
                                        color: sel
                                            ? Colors.transparent
                                            : cs.outlineVariant,
                                        width: 1.5),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    color: sel
                                        ? null
                                        : Colors.transparent,
                                  ),
                                  child: Text(dia,
                                      style: TextStyle(
                                          color: sel
                                              ? Colors.white
                                              : cs.onSurfaceVariant,
                                          fontWeight: sel
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontSize: width * 0.034)),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : _Seccion(
                          titulo: 'Días de operación',
                          child: dias.isEmpty
                              ? Text('Sin días asignados',
                                  style: TextStyle(
                                      color: cs.onSurface
                                          .withValues(alpha: 0.5)))
                              : Wrap(
                                  spacing: width * 0.02,
                                  runSpacing: height * 0.01,
                                  children: dias
                                      .map((dia) => Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.04,
                                                vertical: height * 0.010),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: gradientColors,
                                                begin:
                                                    Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                            ),
                                            child: Text(dia,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize:
                                                        width * 0.034)),
                                          ))
                                      .toList(),
                                ),
                        ),

                  SizedBox(height: height * 0.025),

                  // ── Estado editable ───────────────────────────
                  if (_editando) ...[
                    _SeccionEdicion(
                      titulo: 'Estado de la ruta',
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _activaEdit ? 'Ruta activa' : 'Ruta inactiva',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _activaEdit
                                  ? cs.primary
                                  : cs.onSurfaceVariant),
                        ),
                        subtitle: Text(
                          _activaEdit
                              ? 'Los usuarios pueden ver esta ruta'
                              : 'La ruta no es visible para los usuarios',
                          style: TextStyle(
                              fontSize: width * 0.031,
                              color: cs.onSurfaceVariant),
                        ),
                        secondary: Icon(
                          _activaEdit
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: _activaEdit ? cs.primary : cs.onSurfaceVariant,
                        ),
                        value: _activaEdit,
                        onChanged: (v) => setState(() => _activaEdit = v),
                        activeThumbColor: cs.primary,
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                  ],

                  // ── Mapa (siempre visible) ────────────────────
                  _Seccion(
                    titulo: 'Recorrido de la ruta',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: height * 0.42,
                        child: puntos.length >= 2
                            ? Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCameraFit: bounds != null
                                          ? CameraFit.bounds(
                                              bounds: bounds,
                                              padding: const EdgeInsets.all(40),
                                            )
                                          : null,
                                      initialCenter: puntos.isNotEmpty
                                          ? puntos.first
                                          : const LatLng(20.6736, -103.3440),
                                      initialZoom: 14,
                                      interactionOptions: InteractionOptions(
                                        flags: _mapaLocked
                                            ? InteractiveFlag.none
                                            : InteractiveFlag.all,
                                      ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.rutle',
                                      ),
                                      PolylineLayer(
                                        polylines: [
                                          Polyline(
                                            points: puntos,
                                            color: lineaColor,
                                            strokeWidth: 5,
                                          ),
                                        ],
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: puntos.first,
                                            width: 22,
                                            height: 22,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: lineaColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 3),
                                              ),
                                            ),
                                          ),
                                          Marker(
                                            point: puntos.last,
                                            width: 22,
                                            height: 22,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: lineaColor,
                                                    width: 3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // ── Candado ──────────────────
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: _BtnMapa(
                                      icono: _mapaLocked
                                          ? Icons.lock_rounded
                                          : Icons.lock_open_rounded,
                                      gradColors: gradientColors,
                                      onTap: () => setState(
                                          () => _mapaLocked = !_mapaLocked),
                                    ),
                                  ),

                                  // ── Recentrar ─────────────────
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: _BtnMapa(
                                      icono: Icons.my_location_rounded,
                                      gradColors: gradientColors,
                                      onTap: () {
                                        if (bounds != null) {
                                          _mapController.fitCamera(
                                            CameraFit.bounds(
                                              bounds: bounds,
                                              padding:
                                                  const EdgeInsets.all(40),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: cs.surfaceContainerHighest,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map_outlined,
                                          size: 40,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.3)),
                                      const SizedBox(height: 8),
                                      Text('Sin puntos de ruta',
                                          style: TextStyle(
                                              color: cs.onSurface
                                                  .withValues(
                                                      alpha: 0.4))),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.03),
                ],
              ),
            ),
          ),

          // ── Botones fijos ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
                width * 0.06, height * 0.018, width * 0.06, height * 0.03),
            child: _editando
                ? Row(
                    children: [
                      // Cancelar edición
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _guardando ? null : _cancelarEdicion,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.018),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      // Guardar cambios
                      Expanded(
                        child: ClipRRect(
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
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.018),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ),
                              onPressed:
                                  _guardando ? null : _guardarCambios,
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
                  )
                : Row(
                    children: [
                      // Eliminar
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: const Text('Eliminar'),
                          onPressed: _eliminar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.error,
                            foregroundColor: cs.onError,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.018),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      // Modificar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.018),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ),
                              onPressed: _abrirEdicion,
                              icon: const Icon(Icons.edit_rounded,
                                  size: 18),
                              label: const Text('Modificar'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: TextStyle(
                fontSize: width * 0.042,
                fontWeight: FontWeight.bold,
                color: cs.onSurface)),
        SizedBox(height: height * 0.012),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ],
    );
  }
}

// Igual que _Seccion pero con borde de acento para indicar modo edición
class _SeccionEdicion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _SeccionEdicion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titulo,
                style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, size: 14, color: cs.primary),
          ],
        ),
        SizedBox(height: height * 0.012),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: 0.5), width: 1.5),
          ),
          child: child,
        ),
      ],
    );
  }
}

// Botón circular flotante sobre el mapa (candado / recentrar)
class _BtnMapa extends StatelessWidget {
  final IconData icono;
  final List<Color> gradColors;
  final VoidCallback onTap;

  const _BtnMapa({
    required this.icono,
    required this.gradColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icono, color: Colors.white, size: 18),
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;
  const _InfoFila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.009),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 18),
          SizedBox(width: width * 0.025),
          Expanded(
            flex: 5,
            child: Text(
              etiqueta,
              style: TextStyle(
                  fontSize: width * 0.034,
                  color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              valor,
              style: TextStyle(
                  fontSize: width * 0.034,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
