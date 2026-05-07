import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListaUsuariosPantalla extends StatefulWidget {
  const ListaUsuariosPantalla({super.key});

  @override
  State<ListaUsuariosPantalla> createState() => _ListaUsuariosPantallaState();
}

class _ListaUsuariosPantallaState extends State<ListaUsuariosPantalla> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  bool _match(Map<String, dynamic> data) {
    if (_busqueda.isEmpty) return true;
    final q = _busqueda.toLowerCase();
    final nombre = (data['nombreUsuario'] as String? ?? '').toLowerCase();
    final correo = (data['correo'] as String? ?? '').toLowerCase();
    return nombre.contains(q) || correo.contains(q);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Usuarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ── Lista ─────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .orderBy('nombreUsuario')
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: cs.primary));
                }

                final all = (snap.data?.docs ?? [])
                    .where((d) {
                      final r = (d.data() as Map<String, dynamic>)['rol'];
                      return r == 'recolector' || r == 'admin';
                    })
                    .toList();

                final recolectores = all
                    .where((d) =>
                        (d.data() as Map<String, dynamic>)['rol'] ==
                            'recolector' &&
                        _match(d.data() as Map<String, dynamic>))
                    .toList();

                final admins = all
                    .where((d) =>
                        (d.data() as Map<String, dynamic>)['rol'] == 'admin' &&
                        _match(d.data() as Map<String, dynamic>))
                    .toList();

                if (recolectores.isEmpty && admins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 56,
                            color: cs.onSurface.withValues(alpha: 0.25)),
                        const SizedBox(height: 12),
                        Text(
                          _busqueda.isEmpty
                              ? 'No hay usuarios registrados'
                              : 'Sin resultados para "$_busqueda"',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.04,
                    size.height * 0.015,
                    size.width * 0.04,
                    size.height * 0.02,
                  ),
                  children: [
                    if (recolectores.isNotEmpty) ...[
                      _SeccionHeader(
                        label: 'Recolectores',
                        count: recolectores.length,
                        icono: Icons.directions_bus_rounded,
                        gradColors: gradColors,
                        cs: cs,
                        size: size,
                      ),
                      SizedBox(height: size.height * 0.01),
                      ...recolectores.map((doc) => _TarjetaUsuario(
                            data: doc.data() as Map<String, dynamic>,
                            docId: doc.id,
                            gradColors: gradColors,
                            cs: cs,
                            size: size,
                            isDark: isDark,
                          )),
                      SizedBox(height: size.height * 0.015),
                    ],
                    if (admins.isNotEmpty) ...[
                      _SeccionHeader(
                        label: 'Administradores',
                        count: admins.length,
                        icono: Icons.admin_panel_settings_rounded,
                        gradColors: gradColors,
                        cs: cs,
                        size: size,
                      ),
                      SizedBox(height: size.height * 0.01),
                      ...admins.map((doc) => _TarjetaUsuario(
                            data: doc.data() as Map<String, dynamic>,
                            docId: doc.id,
                            gradColors: gradColors,
                            cs: cs,
                            size: size,
                            isDark: isDark,
                          )),
                    ],
                  ],
                );
              },
            ),
          ),

          // ── Buscador ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * 0.05,
              size.height * 0.016,
              size.width * 0.05,
              size.height * 0.016 +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (v) => setState(() => _busqueda = v.trim()),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o gmail…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: size.height * 0.014),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cabecera de sección ──────────────────────────────────────────────────────

class _SeccionHeader extends StatelessWidget {
  final String label;
  final int count;
  final IconData icono;
  final List<Color> gradColors;
  final ColorScheme cs;
  final Size size;

  const _SeccionHeader({
    required this.label,
    required this.count,
    required this.icono,
    required this.gradColors,
    required this.cs,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.01),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Icon(icono, size: 18, color: gradColors.last),
          SizedBox(width: size.width * 0.02),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.042,
              color: cs.onSurface,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: size.width * 0.033,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de usuario ────────────────────────────────────────────────────────

class _TarjetaUsuario extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final List<Color> gradColors;
  final ColorScheme cs;
  final Size size;
  final bool isDark;

  const _TarjetaUsuario({
    required this.data,
    required this.docId,
    required this.gradColors,
    required this.cs,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = data['nombreUsuario'] as String? ?? '—';
    final correo = data['correo'] as String? ?? '—';
    final fotoUrl = data['fotoUsuario'] as String?;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetalleUsuarioPantalla(data: data, docId: docId),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.011),
        padding: EdgeInsets.all(size.width * 0.038),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: gradColors.first.withValues(alpha: 0.15),
              backgroundImage:
                  fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null
                  ? ShaderMask(
                      shaderCallback: (b) =>
                          LinearGradient(colors: gradColors).createShader(b),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: size.width * 0.035),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.038,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: size.height * 0.003),
                  Row(
                    children: [
                      Icon(Icons.email_rounded,
                          size: 12,
                          color: cs.onSurface.withValues(alpha: 0.45)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          correo,
                          style: TextStyle(
                            fontSize: size.width * 0.031,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

// ─── Detalle de usuario ───────────────────────────────────────────────────────

class DetalleUsuarioPantalla extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetalleUsuarioPantalla({
    super.key,
    required this.data,
    required this.docId,
  });

  String _formatFecha(dynamic ts) {
    if (ts == null) return '—';
    if (ts is! Timestamp) return '—';
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

    final nombre = data['nombreUsuario'] as String? ?? '—';
    final correo = data['correo'] as String? ?? '—';
    final rol = data['rol'] as String? ?? '—';
    final fotoUrl = data['fotoUsuario'] as String?;
    final fecha = _formatFecha(data['fechaRegistro']);
    final reportes = data['reportes'] ?? 0;
    final horario = data['horario'] as Map<String, dynamic>?;

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
          nombre,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),

            // ── Avatar ────────────────────────────────────────────
            CircleAvatar(
              radius: 48,
              backgroundColor: gradColors.first.withValues(alpha: 0.15),
              backgroundImage:
                  fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null
                  ? ShaderMask(
                      shaderCallback: (b) =>
                          LinearGradient(colors: gradColors).createShader(b),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(height: size.height * 0.012),

            // Rol badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.006,
              ),
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: gradColors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rol == 'recolector' ? 'Recolector' : 'Administrador',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // ── Información ───────────────────────────────────────
            _SeccionInfo(
              titulo: 'Información de cuenta',
              gradColors: gradColors,
              cs: cs,
              size: size,
              isDark: isDark,
              filas: [
                if (data['idEmpleado'] != null)
                  _FilaInfo(icono: Icons.badge_rounded, etiqueta: 'ID', valor: '#${data['idEmpleado']}'),
                _FilaInfo(icono: Icons.person_rounded, etiqueta: 'Usuario', valor: nombre),
                _FilaInfo(icono: Icons.email_rounded, etiqueta: 'Gmail', valor: correo),
                _FilaInfo(icono: Icons.calendar_today_rounded, etiqueta: 'Registro', valor: fecha),
                _FilaInfo(icono: Icons.warning_amber_rounded, etiqueta: 'Reportes', valor: '$reportes'),
              ],
            ),

            // ── Horario (solo recolector) ─────────────────────────
            if (rol == 'recolector' && horario != null && horario.isNotEmpty) ...[
              SizedBox(height: size.height * 0.02),
              _SeccionHorario(
                horario: horario,
                gradColors: gradColors,
                cs: cs,
                size: size,
                isDark: isDark,
              ),
            ],

            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }
}

// ─── Sección de info ──────────────────────────────────────────────────────────

class _FilaInfo {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaInfo(
      {required this.icono, required this.etiqueta, required this.valor});
}

class _SeccionInfo extends StatelessWidget {
  final String titulo;
  final List<_FilaInfo> filas;
  final List<Color> gradColors;
  final ColorScheme cs;
  final Size size;
  final bool isDark;

  const _SeccionInfo({
    required this.titulo,
    required this.filas,
    required this.gradColors,
    required this.cs,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
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
                  colors: gradColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Filas
          ...filas.map((f) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.012,
                ),
                child: Row(
                  children: [
                    Icon(f.icono,
                        size: 18,
                        color: gradColors.last.withValues(alpha: 0.8)),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      '${f.etiqueta}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.035,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        f.valor,
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Sección de horario ───────────────────────────────────────────────────────

class _SeccionHorario extends StatelessWidget {
  final Map<String, dynamic> horario;
  final List<Color> gradColors;
  final ColorScheme cs;
  final Size size;
  final bool isDark;

  static const _orden = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  const _SeccionHorario({
    required this.horario,
    required this.gradColors,
    required this.cs,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dias = _orden.where((d) => horario.containsKey(d)).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.012,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: gradColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 6),
                const Text(
                  'Horario laboral',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ...dias.map((dia) {
            final h = horario[dia] as Map<String, dynamic>? ?? {};
            final inicio = h['inicio'] as String? ?? '—';
            final fin = h['fin'] as String? ?? '—';
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.011,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.24,
                    child: Text(
                      dia,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.034,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.login_rounded,
                      size: 14,
                      color: gradColors.last.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text(inicio,
                      style: TextStyle(
                          fontSize: size.width * 0.034, color: cs.onSurface)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                  ),
                  Icon(Icons.logout_rounded,
                      size: 14,
                      color: gradColors.last.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text(fin,
                      style: TextStyle(
                          fontSize: size.width * 0.034, color: cs.onSurface)),
                ],
              ),
            );
          }),
          SizedBox(height: size.height * 0.004),
        ],
      ),
    );
  }
}
