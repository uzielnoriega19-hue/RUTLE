import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'info_ruta_pantalla.dart';

class VerRutasPantalla extends StatelessWidget {
  const VerRutasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final gradientColors = isDark
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
        title: const Text('Ver Rutas',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rutas')
            .orderBy('creadoEn', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: cs.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar rutas',
                  style: TextStyle(color: cs.error)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.route,
                      size: 64,
                      color: cs.onSurface.withValues(alpha: 0.25)),
                  SizedBox(height: height * 0.02),
                  Text(
                    'No hay rutas creadas',
                    style: TextStyle(
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            itemCount: docs.length,
            separatorBuilder: (_, _) => SizedBox(height: height * 0.015),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _RutaCard(
                data: data,
                gradientColors: gradientColors,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InfoRutaPantalla(
                      docId: doc.id,
                      data: data,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Tarjeta de ruta ─────────────────────────────────────────────

class _RutaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RutaCard({
    required this.data,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final nombre = data['nombre'] as String? ?? '—';
    final dias = List<String>.from(data['dias'] as List? ?? []);
    final activa = data['activa'] as bool? ?? true;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.045, vertical: height * 0.018),
          child: Row(
            children: [
              // Ícono con gradiente
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route, color: Colors.white, size: 24),
              ),
              SizedBox(width: width * 0.04),

              // Nombre + días
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ruta $nombre',
                          style: TextStyle(
                              fontSize: width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: activa
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activa ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                                fontSize: width * 0.028,
                                fontWeight: FontWeight.w600,
                                color:
                                    activa ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.006),
                    if (dias.isNotEmpty)
                      Text(
                        dias.join(' · '),
                        style: TextStyle(
                            fontSize: width * 0.032,
                            color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Sin días asignados',
                        style: TextStyle(
                            fontSize: width * 0.032,
                            color: cs.onSurface.withValues(alpha: 0.35)),
                      ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
