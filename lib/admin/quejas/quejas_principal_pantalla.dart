import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detalle_queja_pantalla.dart';

class QuejasPrincipalPantalla extends StatelessWidget {
  const QuejasPrincipalPantalla({super.key});

  String _formatFecha(Timestamp? ts) {
    if (ts == null) return '—';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

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
        title: const Text('Quejas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatbot')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 56,
                      color: cs.onSurface.withValues(alpha: 0.25)),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    'No hay quejas registradas',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          // Agrupar por colonia
          final Map<String, List<QueryDocumentSnapshot>> porColonia = {};
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final col = (data['colonia'] as String?)?.trim();
            final key = (col == null || col.isEmpty) ? 'Sin colonia' : col;
            porColonia.putIfAbsent(key, () => []).add(doc);
          }
          final colonias = porColonia.keys.toList()
            ..sort((a, b) {
              if (a == 'Sin colonia') return 1;
              if (b == 'Sin colonia') return -1;
              return a.compareTo(b);
            });

          return ListView(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.04,
              size.height * 0.01,
              size.width * 0.04,
              size.height * 0.13,
            ),
            children: [
              for (final colonia in colonias) ...[
                Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.02, bottom: size.height * 0.01),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: size.width * 0.025),
                      Text(colonia,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.042,
                            color: cs.onSurface,
                          )),
                      SizedBox(width: size.width * 0.02),
                      Text('(${porColonia[colonia]!.length})',
                          style: TextStyle(
                            fontSize: size.width * 0.033,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          )),
                    ],
                  ),
                ),
                for (final doc in porColonia[colonia]!) ...[
                  _TarjetaQueja(
                    data: doc.data() as Map<String, dynamic>,
                    docId: doc.id,
                    fechaStr: _formatFecha(
                        (doc.data() as Map<String, dynamic>)['fecha']
                            as Timestamp?),
                    gradColors: gradColors,
                    isDark: isDark,
                    cs: cs,
                    size: size,
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaQueja extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final String fechaStr;
  final List<Color> gradColors;
  final bool isDark;
  final ColorScheme cs;
  final Size size;

  const _TarjetaQueja({
    required this.data,
    required this.docId,
    required this.fechaStr,
    required this.gradColors,
    required this.isDark,
    required this.cs,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = data['nombreUsuario'] as String? ?? 'Usuario';
    final dir = data['direccion'] as String? ?? '—';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleQuejaPantalla(data: data, docId: docId),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.012),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.22),
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
        child: Row(
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            SizedBox(width: size.width * 0.035),

            // Datos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icono: Icons.person_rounded,
                    texto: nombre,
                    bold: true,
                    cs: cs,
                    size: size,
                  ),
                  SizedBox(height: size.height * 0.004),
                  _InfoRow(
                    icono: Icons.location_on_rounded,
                    texto: dir,
                    cs: cs,
                    size: size,
                  ),
                  SizedBox(height: size.height * 0.004),
                  _InfoRow(
                    icono: Icons.calendar_today_rounded,
                    texto: fechaStr,
                    cs: cs,
                    size: size,
                    small: true,
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool bold;
  final bool small;
  final ColorScheme cs;
  final Size size;

  const _InfoRow({
    required this.icono,
    required this.texto,
    required this.cs,
    required this.size,
    this.bold = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final alpha = small ? 0.45 : (bold ? 0.65 : 0.5);
    return Row(
      children: [
        Icon(icono,
            size: small ? 12 : 13,
            color: cs.onSurface.withValues(alpha: alpha)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: small ? size.width * 0.03 : size.width * 0.035,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
