import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleQuejaPantalla extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetalleQuejaPantalla({
    super.key,
    required this.data,
    required this.docId,
  });

  static const _etiquetas = {
    'inicio': 'Categoría',
    'rutas': 'Tipo de problema vial',
    'ruta_detalle': 'Acción',
    'ruta_texto': 'Detalle',
    'recolectores': 'Tipo de problema',
    'recolector_detalle': 'Acción',
    'recolector_texto': 'Detalle',
    'app': 'Tipo de error',
    'app_detalle': 'Acción',
    'app_texto': 'Detalle',
    'foros': 'Tipo de problema en foro',
    'foro_detalle': 'Acción',
    'foro_texto': 'Detalle',
  };

  String _formatFecha(Timestamp? ts) {
    if (ts == null) return '—';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final nombre = data['nombreUsuario'] as String? ?? '—';
    final correo = data['correo'] as String? ?? '—';
    final dir = data['direccion'] as String? ?? '—';
    final colonia = data['colonia'] as String? ?? '—';
    final fecha = data['fecha'] as Timestamp?;

    final historial = (data['historial'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

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
        title: const Text('Detalle de queja',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.05,
          size.height * 0.025,
          size.width * 0.05,
          size.height * 0.05,
        ),
        children: [
          // ── Usuario ───────────────────────────────────────────
          _Seccion(
            titulo: 'Usuario',
            icono: Icons.person_rounded,
            isDark: isDark,
            cs: cs,
            size: size,
            gradColors: gradColors,
            children: [
              _Fila(label: 'Nombre', valor: nombre, cs: cs, size: size),
              _Fila(label: 'Correo', valor: correo, cs: cs, size: size),
              _Fila(label: 'Dirección', valor: dir, cs: cs, size: size),
              _Fila(label: 'Colonia', valor: colonia, cs: cs, size: size),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          // ── Fecha ─────────────────────────────────────────────
          _Seccion(
            titulo: 'Fecha',
            icono: Icons.calendar_today_rounded,
            isDark: isDark,
            cs: cs,
            size: size,
            gradColors: gradColors,
            children: [
              _Fila(
                  label: 'Enviado',
                  valor: _formatFecha(fecha),
                  cs: cs,
                  size: size),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          // ── Reporte (historial) ───────────────────────────────
          _Seccion(
            titulo: 'Reporte',
            icono: Icons.message_rounded,
            isDark: isDark,
            cs: cs,
            size: size,
            gradColors: gradColors,
            children: [
              if (historial.isEmpty)
                Text(
                  'Sin historial',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: size.width * 0.035),
                )
              else
                for (int i = 0; i < historial.length; i++) ...[
                  _PasoHistorial(
                    paso: i + 1,
                    etiqueta: _etiquetas[historial[i]['nodo']] ??
                        (historial[i]['nodo'] as String? ?? ''),
                    respuesta: historial[i]['respuesta'] as String? ?? '—',
                    cs: cs,
                    size: size,
                  ),
                  if (i < historial.length - 1)
                    Divider(
                      height: size.height * 0.02,
                      color: cs.outline.withValues(alpha: 0.12),
                    ),
                ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sección con encabezado ───────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool isDark;
  final ColorScheme cs;
  final Size size;
  final List<Color> gradColors;
  final List<Widget> children;

  const _Seccion({
    required this.titulo,
    required this.icono,
    required this.isDark,
    required this.cs,
    required this.size,
    required this.gradColors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.012,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradColors[0].withValues(alpha: 0.15),
                  gradColors[1].withValues(alpha: 0.08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icono, size: 16, color: gradColors[1]),
                SizedBox(width: size.width * 0.02),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.038,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila label : valor ───────────────────────────────────────────────────────

class _Fila extends StatelessWidget {
  final String label;
  final String valor;
  final ColorScheme cs;
  final Size size;

  const _Fila({
    required this.label,
    required this.valor,
    required this.cs,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.009),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.22,
            child: Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.033,
                color: cs.onSurface.withValues(alpha: 0.52),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Paso del historial ───────────────────────────────────────────────────────

class _PasoHistorial extends StatelessWidget {
  final int paso;
  final String etiqueta;
  final String respuesta;
  final ColorScheme cs;
  final Size size;

  const _PasoHistorial({
    required this.paso,
    required this.etiqueta,
    required this.respuesta,
    required this.cs,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$paso',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (etiqueta.isNotEmpty)
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              Text(
                respuesta,
                style: TextStyle(
                  fontSize: size.width * 0.036,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
