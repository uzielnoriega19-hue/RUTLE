import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rutle_test/modulos/foros/pantallas/info_foro_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/accion_poder_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/accion_usuario_pantalla.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _mensajeController = TextEditingController();

  Future<void> enviarMensaje() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final nombre = userDoc.data()?['nombreUsuario'] ?? 'Usuario';

    await FirebaseFirestore.instance.collection('chatforo').add({
      'titulo': widget.titulo,
      'descripcion': widget.descripcion,
      'mensaje': texto,
      'uid': user.uid,
      'nombre': nombre,
      'fecha': FieldValue.serverTimestamp(),
      'tipo': 'normal',
    });

    _mensajeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                  : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          widget.titulo,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () async {
              final query = await FirebaseFirestore.instance
                  .collection('foros')
                  .where('titulo', isEqualTo: widget.titulo)
                  .where('descripcion', isEqualTo: widget.descripcion)
                  .limit(1)
                  .get();

              if (query.docs.isEmpty) return;

              final foro = query.docs.first.data();

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InfoForoPantalla(foro: foro),
                ),
              );

              if (result == true) {
                Navigator.pop(context);
              }
            },
          ),
        ],
        centerTitle: true,
      ),

      body: Column(
        children: [
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
                  return const Center(child: CircularProgressIndicator());
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(size.width * 0.04),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final data =
                        mensajes[index].data() as Map<String, dynamic>;

                    final mensaje = data['mensaje'] ?? '';
                    final nombre = data['nombre'] ?? 'Usuario';
                    final uid = data['uid'];
                    final tipo = data['tipo'] ?? 'normal';
                    final fecha =
                        (data['fecha'] as Timestamp?)?.toDate();

                    final esMio = uid == currentUser?.uid;

                    final hora = fecha != null
                        ? '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
                        : '';

                    // 🚫 MENSAJES SISTEMA
                    final cs = Theme.of(context).colorScheme;

                    if (tipo == 'sistema') {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        child: Text(
                          mensaje,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,

                      // 🚫 LONG PRESS CONTROLADO
                      onLongPress: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) return;

                        if (uid == currentUser.uid) return;

                        final db = FirebaseFirestore.instance;

                        final query = await db
                            .collection('foros')
                            .where('titulo', isEqualTo: widget.titulo)
                            .where('descripcion', isEqualTo: widget.descripcion)
                            .limit(1)
                            .get();

                        if (query.docs.isEmpty) return;

                        final foroData = query.docs.first.data();

                        final miembros = (foroData['miembros'] as List?) ?? [];

                        bool sigueEnElForo = false;

                        String rolActual = 'miembro';

                        for (var m in miembros) {
                          if (m is Map && m['uid'] == uid) {
                            sigueEnElForo = true;
                            break;
                          }
                        }

                        if (!sigueEnElForo) return;

                        if (foroData['creadorId'] == currentUser.uid) {
                          rolActual = 'admin';
                        } else {
                          for (var m in miembros) {
                            if (m is Map && m['uid'] == currentUser.uid) {
                              rolActual = m['rol'] ?? 'miembro';
                              break;
                            }
                          }
                        }

                        final esAdminOModerador =
                            rolActual == 'admin' || rolActual == 'moderador';

                        if (esAdminOModerador) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccionPoderPantalla(
                                nombre: nombre,
                                uid: uid ?? '',
                                titulo: widget.titulo,
                                descripcion: widget.descripcion,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccionUsuarioPantalla(
                                nombre: nombre,
                                uid: uid ?? '',
                                titulo: widget.titulo,
                                descripcion: widget.descripcion,
                              ),
                            ),
                          );
                        }
                      },

                      child: Row(
                        mainAxisAlignment: esMio
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: size.width * 0.7,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: esMio
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(esMio ? 14 : 4),
                                bottomRight: Radius.circular(esMio ? 4 : 14),
                              ),
                              border: Border.all(
                                color: esMio
                                    ? cs.primary.withValues(alpha: 0.25)
                                    : cs.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre + reportes
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('usuarios')
                                      .doc(uid)
                                      .get(),
                                  builder: (context, snapUser) {
                                    int reportes = 0;

                                    if (snapUser.hasData &&
                                        snapUser.data!.data() != null) {
                                      final dataUser = snapUser.data!.data()
                                          as Map<String, dynamic>;
                                      reportes = dataUser['reportes'] ?? 0;
                                    }

                                    return Row(
                                      children: [
                                        Text(
                                          nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: esMio
                                                ? cs.onPrimaryContainer
                                                : cs.onSurface,
                                          ),
                                        ),
                                        if (reportes > 0) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.warning_amber,
                                            color: cs.error,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$reportes',
                                            style: TextStyle(
                                              color: cs.error,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  mensaje,
                                  style: TextStyle(
                                    color: esMio
                                        ? cs.onPrimaryContainer
                                        : cs.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    hora,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: esMio
                                          ? cs.onPrimaryContainer
                                              .withValues(alpha: 0.65)
                                          : cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: enviarMensaje,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}