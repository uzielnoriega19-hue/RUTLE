import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'seleccionar_zona_ruta_pantalla.dart';

const _gdl = LatLng(20.6736, -103.3440);

const _dias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class CrearRutaPantalla extends StatefulWidget {
  const CrearRutaPantalla({super.key});

  @override
  State<CrearRutaPantalla> createState() => _CrearRutaPantallaState();
}

class _CrearRutaPantallaState extends State<CrearRutaPantalla> {
  final _rutaController = TextEditingController();
  final Set<String> _diasSeleccionados = {};
  List<LatLng> _puntosRuta = [];
  bool _activa = true;
  bool _guardando = false;

  @override
  void dispose() {
    _rutaController.dispose();
    super.dispose();
  }

  bool get _puedeGuardar =>
      RegExp(r'^[A-Za-z]\d{1,3}$').hasMatch(_rutaController.text) &&
      _diasSeleccionados.isNotEmpty &&
      _puntosRuta.isNotEmpty;

  // ─── Guardar en Firestore ─────────────────────────────────────

  Future<void> _guardar() async {
    if (!_puedeGuardar || _guardando) return;
    setState(() => _guardando = true);

    try {
      final nombre = _rutaController.text.trim();

      // Verificar si ya existe una ruta con ese nombre exacto
      final duplicado = await FirebaseFirestore.instance
          .collection('rutas')
          .where('nombre', isEqualTo: nombre)
          .limit(1)
          .get();

      if (duplicado.docs.isNotEmpty) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nombre duplicado'),
              content: Text(
                'Ya existe una ruta con el nombre "$nombre".\nCambia el nombre e intenta de nuevo.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final diasOrdenados =
          _dias.where((d) => _diasSeleccionados.contains(d)).toList();

      await FirebaseFirestore.instance.collection('rutas').add({
        'nombre': nombre,
        'dias': diasOrdenados,
        'puntos': _puntosRuta
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'totalPuntos': _puntosRuta.length,
        'activa': _activa,
        'creadoEn': FieldValue.serverTimestamp(),
        'creadoPor': uid,
      });

      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (mounted) {
        _mostrarError('Error de Firebase: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error inesperado: $e');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nueva ruta',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Nombre de ruta ──────────────────────
                  Text('Ruta',
                      style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),

                  SizedBox(height: height * 0.012),

                  // "Ruta:" siempre visible como widget externo al campo
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            'Ruta:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.038,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _rutaController,
                            maxLength: 4,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [_RutaFormatter()],
                            decoration: InputDecoration(
                              hintText: 'A123',
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.018),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ── Días ────────────────────────────────
                  Text('Días',
                      style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),

                  SizedBox(height: height * 0.015),

                  Wrap(
                    spacing: width * 0.02,
                    runSpacing: height * 0.01,
                    children: _dias.map((dia) {
                      final sel = _diasSeleccionados.contains(dia);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel
                              ? _diasSeleccionados.remove(dia)
                              : _diasSeleccionados.add(dia);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.012),
                          decoration: BoxDecoration(
                            gradient: sel
                                ? LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight)
                                : null,
                            border: Border.all(
                                color: sel
                                    ? Colors.transparent
                                    : cs.outlineVariant,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            color: sel ? null : Colors.transparent,
                          ),
                          child: Text(dia,
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : cs.onSurfaceVariant,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: width * 0.035)),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: height * 0.03),

                  // ── Estado ──────────────────────────────
                  Text('Estado',
                      style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),

                  SizedBox(height: height * 0.012),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04),
                      title: Text(
                        _activa ? 'Ruta activa' : 'Ruta inactiva',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.038,
                            color: _activa ? cs.primary : cs.onSurfaceVariant),
                      ),
                      subtitle: Text(
                        _activa
                            ? 'Los usuarios podrán ver esta ruta'
                            : 'La ruta no será visible para los usuarios',
                        style: TextStyle(
                            fontSize: width * 0.032,
                            color: cs.onSurfaceVariant),
                      ),
                      secondary: Icon(
                        _activa
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _activa ? cs.primary : cs.onSurfaceVariant,
                      ),
                      value: _activa,
                      onChanged: (v) => setState(() => _activa = v),
                      activeThumbColor: cs.primary,
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ── Zona de recolección ─────────────────
                  Text('Zona de recolección',
                      style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),

                  SizedBox(height: height * 0.012),

                  // Preview del mapa con la ruta real dibujada
                  GestureDetector(
                    onTap: () async {
                      final resultado =
                          await Navigator.push<List<LatLng>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SeleccionarZonaRutaPantalla(),
                        ),
                      );
                      if (resultado != null && mounted) {
                        setState(() => _puntosRuta = resultado);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: height * 0.28,
                        child: Stack(
                          children: [
                            // Mapa con la ruta trazada
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: _puntosRuta.isNotEmpty
                                    ? _puntosRuta.first
                                    : _gdl,
                                initialZoom: 14,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.rutle',
                                ),
                                if (_puntosRuta.length >= 2)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: _puntosRuta,
                                        color: lineaColor,
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),
                                if (_puntosRuta.isNotEmpty)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _puntosRuta.first,
                                        width: 16,
                                        height: 16,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: lineaColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Overlay semitransparente con texto
                            Container(
                              decoration: BoxDecoration(
                                color: _puntosRuta.isEmpty
                                    ? Colors.black
                                        .withValues(alpha: 0.40)
                                    : Colors.black
                                        .withValues(alpha: 0.22),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _puntosRuta.isEmpty
                                          ? Icons.touch_app_rounded
                                          : Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                    SizedBox(height: height * 0.01),
                                    Text(
                                      _puntosRuta.isEmpty
                                          ? 'Toca para trazar la ruta'
                                          : 'Ruta trazada  •  ${_puntosRuta.length} puntos\nToca para editar',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.037,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),

          // ── Botones fijos ─────────────────────────────
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
                width * 0.06, height * 0.022, width * 0.06, height * 0.03),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _guardando ? null : () => Navigator.pop(context),
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
                Expanded(
                  child: Opacity(
                    opacity: _puedeGuardar ? 1.0 : 0.45,
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
                              _puedeGuardar && !_guardando
                                  ? _guardar
                                  : null,
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
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
          ),
        ],
      ),
    );
  }
}

// ─── Formatter del campo de ruta ─────────────────────────────────

class _RutaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'[A-Za-z]').hasMatch(text[0])) return oldValue;

    if (text.length > 1) {
      final numeros = text.substring(1);
      if (!RegExp(r'^\d+$').hasMatch(numeros)) return oldValue;
    }

    final formatted = text[0].toUpperCase() + text.substring(1);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
