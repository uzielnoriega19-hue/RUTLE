import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutle_test/modulos/foros/pantallas/info_foro_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/accion_poder_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/accion_usuario_pantalla.dart';

class ChatForoPantalla extends StatefulWidget {
  final String titulo;
  final String descripcion;

  const ChatForoPantalla({
    super.key,
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<ChatForoPantalla> createState() => _ChatForoPantallaState();
}

class _ChatForoPantallaState extends State<ChatForoPantalla> {
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();

  // Mensaje al que se está respondiendo
  Map<String, dynamic>? _respondiendo;

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Enviar mensaje ──────────────────────────────────────────

  Future<void> _enviarMensaje() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    final nombre = userDoc.data()?['nombreUsuario'] ?? 'Usuario';
    final fotoUrl = userDoc.data()?['fotoUsuario'] ?? '';

    final doc = <String, dynamic>{
      'titulo': widget.titulo,
      'descripcion': widget.descripcion,
      'mensaje': texto,
      'uid': user.uid,
      'nombre': nombre,
      'fotoUrl': fotoUrl,
      'fecha': FieldValue.serverTimestamp(),
      'tipo': 'normal',
      if (_respondiendo != null) 'respondiendo': _respondiendo,
    };

    await FirebaseFirestore.instance.collection('chatforo').add(doc);
    _mensajeController.clear();
    setState(() => _respondiendo = null);

    // Scroll al final
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Long-press: menú de acciones ────────────────────────────

  Future<void> _onLongPress(
      BuildContext ctx, Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = data['uid'] as String?;
    final nombre = data['nombre'] as String? ?? 'Usuario';
    final mensaje = data['mensaje'] as String? ?? '';
    final esMio = uid == currentUser.uid;

    final nav = Navigator.of(ctx);

    // Opciones disponibles
    final opciones = <_Opcion>[
      _Opcion(Icons.reply_rounded, 'Responder', Colors.blue),
      if (!esMio) _Opcion(Icons.warning_amber_rounded, 'Acción', Colors.orange),
    ];

    final sel = await showModalBottomSheet<String>(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tirador
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(bCtx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Preview del mensaje
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  mensaje,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(bCtx).colorScheme.onSurfaceVariant),
                ),
              ),
              const Divider(height: 1),
              ...opciones.map((o) => ListTile(
                    leading: Icon(o.icono, color: o.color),
                    title: Text(o.texto,
                        style: TextStyle(color: o.color)),
                    onTap: () => Navigator.pop(bCtx, o.texto),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (sel == null || !mounted) return;

    if (sel == 'Responder') {
      setState(() => _respondiendo = {
            'nombre': nombre,
            'mensaje': mensaje,
            'uid': uid,
          });
      return;
    }

    if (sel == 'Acción' && !esMio) {
      // Determinar rol del usuario actual en el foro
      final query = await FirebaseFirestore.instance
          .collection('foros')
          .where('titulo', isEqualTo: widget.titulo)
          .where('descripcion', isEqualTo: widget.descripcion)
          .limit(1)
          .get();

      if (query.docs.isEmpty || !mounted) return;
      final foroData = query.docs.first.data();
      final miembros = (foroData['miembros'] as List?) ?? [];

      bool sigueEnElForo = miembros.any(
          (m) => m is Map && m['uid'] == uid);
      if (!sigueEnElForo) return;

      String rolActual = 'miembro';
      if (foroData['creadorId'] == currentUser.uid) {
        rolActual = 'admin';
      } else {
        for (final m in miembros) {
          if (m is Map && m['uid'] == currentUser.uid) {
            rolActual = m['rol'] ?? 'miembro';
            break;
          }
        }
      }

      final esAdminOMod = rolActual == 'admin' || rolActual == 'moderador';
      if (!mounted) return;

      nav.push(
        MaterialPageRoute(
          builder: (_) => esAdminOMod
              ? AccionPoderPantalla(
                  nombre: nombre,
                  uid: uid ?? '',
                  titulo: widget.titulo,
                  descripcion: widget.descripcion,
                )
              : AccionUsuarioPantalla(
                  nombre: nombre,
                  uid: uid ?? '',
                  titulo: widget.titulo,
                  descripcion: widget.descripcion,
                ),
        ),
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        title: Text(widget.titulo,
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () async {
              final nav = Navigator.of(context);
              final query = await FirebaseFirestore.instance
                  .collection('foros')
                  .where('titulo', isEqualTo: widget.titulo)
                  .where('descripcion', isEqualTo: widget.descripcion)
                  .limit(1)
                  .get();
              if (query.docs.isEmpty || !mounted) return;
              final result = await nav.push(
                MaterialPageRoute(
                  builder: (_) =>
                      InfoForoPantalla(foro: query.docs.first.data()),
                ),
              );
              if (result == true && mounted) nav.pop();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Lista de mensajes ─────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatforo')
                  .where('titulo', isEqualTo: widget.titulo)
                  .where('descripcion', isEqualTo: widget.descripcion)
                  .orderBy('fecha', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(color: cs.primary));
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.01),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final data =
                        mensajes[index].data() as Map<String, dynamic>;

                    final mensaje = data['mensaje'] ?? '';
                    final nombre = data['nombre'] ?? 'Usuario';
                    final uid = data['uid'] as String?;
                    final tipo = data['tipo'] ?? 'normal';
                    final fotoUrl = data['fotoUrl'] as String?;
                    final respondiendo =
                        data['respondiendo'] as Map<String, dynamic>?;
                    final fecha =
                        (data['fecha'] as Timestamp?)?.toDate();
                    final hora = fecha != null
                        ? '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
                        : '';
                    final esMio = uid == currentUser?.uid;

                    // Mensaje de sistema
                    if (tipo == 'sistema') {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        child: Text(
                          mensaje,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: cs.onSurfaceVariant),
                        ),
                      );
                    }

                    return GestureDetector(
                      onLongPress: () => _onLongPress(context, data),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.010),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: esMio
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            // Avatar del otro usuario
                            if (!esMio) ...[
                              _Avatar(fotoUrl: fotoUrl, size: 34),
                              const SizedBox(width: 6),
                            ],

                            // Burbuja del mensaje
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: size.width * 0.72),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: esMio
                                      ? cs.primaryContainer
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft:
                                        Radius.circular(esMio ? 14 : 4),
                                    bottomRight:
                                        Radius.circular(esMio ? 4 : 14),
                                  ),
                                  border: Border.all(
                                    color: esMio
                                        ? cs.primary.withValues(alpha: 0.25)
                                        : cs.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Nombre + reportes
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('usuarios')
                                          .doc(uid)
                                          .get(),
                                      builder: (context, snap) {
                                        final reportes = snap.hasData &&
                                                snap.data!.data() != null
                                            ? ((snap.data!.data()
                                                    as Map<String,
                                                        dynamic>)['reportes'] ??
                                                0)
                                            : 0;
                                        return Row(
                                          children: [
                                            Text(
                                              nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: esMio
                                                    ? cs.onPrimaryContainer
                                                    : cs.onSurface,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (reportes > 0) ...[
                                              const SizedBox(width: 6),
                                              Icon(Icons.warning_amber,
                                                  color: cs.error, size: 14),
                                              Text('$reportes',
                                                  style: TextStyle(
                                                      color: cs.error,
                                                      fontSize: 11)),
                                            ],
                                          ],
                                        );
                                      },
                                    ),

                                    // Cita del mensaje respondido
                                    if (respondiendo != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: esMio
                                              ? cs.primary.withValues(
                                                  alpha: 0.15)
                                              : cs.outline
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border(
                                            left: BorderSide(
                                              color: cs.primary, width: 3),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              respondiendo['nombre'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: cs.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              respondiendo['mensaje'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: esMio
                                                    ? cs.onPrimaryContainer
                                                        .withValues(alpha: 0.75)
                                                    : cs.onSurface
                                                        .withValues(
                                                            alpha: 0.65),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 4),

                                    // Texto del mensaje
                                    Text(
                                      mensaje,
                                      style: TextStyle(
                                        color: esMio
                                            ? cs.onPrimaryContainer
                                            : cs.onSurface,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    // Hora
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        hora,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: esMio
                                              ? cs.onPrimaryContainer
                                                  .withValues(alpha: 0.6)
                                              : cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Preview de respuesta ──────────────────────────────
          if (_respondiendo != null)
            Container(
              color: cs.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _respondiendo!['nombre'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: cs.primary),
                        ),
                        Text(
                          _respondiendo!['mensaje'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _respondiendo = null),
                  ),
                ],
              ),
            ),

          // ── Campo de texto ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _enviarMensaje,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
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

class _Avatar extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  const _Avatar({required this.fotoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage:
          (fotoUrl != null && fotoUrl!.isNotEmpty)
              ? NetworkImage(fotoUrl!)
              : null,
      child: (fotoUrl == null || fotoUrl!.isEmpty)
          ? Icon(Icons.person_rounded,
              size: size * 0.55,
              color: Theme.of(context).colorScheme.onSurfaceVariant)
          : null,
    );
  }
}

class _Opcion {
  final IconData icono;
  final String texto;
  final Color color;
  const _Opcion(this.icono, this.texto, this.color);
}
