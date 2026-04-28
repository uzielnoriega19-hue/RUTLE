import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutle_test/modulos/foros/widgets/badge_privacidad.dart';

class InfoForoPantalla extends StatelessWidget {
  final Map<String, dynamic> foro;

  const InfoForoPantalla({super.key, required this.foro});

  Future<void> _cambiarPrivacidad(
      BuildContext context, String privacidadActual) async {
    final nuevaPrivacidad =
        privacidadActual == 'privado' ? 'publico' : 'privado';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar privacidad'),
        content: Text(
          'El foro cambiará a '
          '${nuevaPrivacidad == 'privado' ? 'Privado' : 'Público'}. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final db = FirebaseFirestore.instance;
    final query = await db
        .collection('foros')
        .where('titulo', isEqualTo: foro['titulo'])
        .where('descripcion', isEqualTo: foro['descripcion'])
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;
    await query.docs.first.reference.update({'privacidad': nuevaPrivacidad});

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Foro cambiado a ${nuevaPrivacidad == 'privado' ? 'Privado' : 'Público'}',
        ),
      ),
    );
  }

  Future<void> _accionForo(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;

    final query = await db
        .collection('foros')
        .where('titulo', isEqualTo: foro['titulo'])
        .where('descripcion', isEqualTo: foro['descripcion'])
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final foroDoc = query.docs.first;
    final foroRef = foroDoc.reference;

    final esCreador = foroDoc.data()['creadorId'] == user.uid;

    final userDoc = await db.collection('usuarios').doc(user.uid).get();
    final nombreUsuario = userDoc.data()?['nombreUsuario'] ?? 'Usuario';

    if (esCreador) {
      final mensajes = await db
          .collection('chatforo')
          .where('titulo', isEqualTo: foro['titulo'])
          .where('descripcion', isEqualTo: foro['descripcion'])
          .get();

      for (var doc in mensajes.docs) {
        await doc.reference.delete();
      }

      await foroRef.delete();

      await db.collection('chatforo').add({
        'titulo': foro['titulo'],
        'descripcion': foro['descripcion'],
        'mensaje': 'El foro fue eliminado por el creador',
        'tipo': 'sistema',
        'nombre': 'Sistema',
        'uid': '',
        'fecha': FieldValue.serverTimestamp(),
      });
    } else {
      final miembros = (foroDoc.data()['miembros'] as List?) ?? [];

      Map<String, dynamic>? miembroAEliminar;

      for (var m in miembros) {
        if (m is Map && m['uid'] == user.uid) {
          miembroAEliminar = Map<String, dynamic>.from(m);
          break;
        }
      }

      if (miembroAEliminar != null) {
        await foroRef.update({
          'miembros': FieldValue.arrayRemove([miembroAEliminar])
        });

        await db.collection('chatforo').add({
          'titulo': foro['titulo'],
          'descripcion': foro['descripcion'],
          'mensaje': '$nombreUsuario salió del foro',
          'tipo': 'sistema',
          'nombre': 'Sistema',
          'uid': '',
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    final miembros = (foro['miembros'] as List?) ?? [];
    final rutas = (foro['rutas'] as List?) ?? [];
    final fechaRaw = foro['fechaCreacion'];
    final fecha =
        fechaRaw is Timestamp ? fechaRaw.toDate() : DateTime.now();

    final currentUser = FirebaseAuth.instance.currentUser;
    final esCreador = currentUser?.uid == foro['creadorId'];
    final privacidad = foro['privacidad'] ?? 'publico';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02),

                      // Ícono del foro
                      Container(
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.forum_rounded,
                          size: size.width * 0.15,
                          color: cs.onPrimaryContainer,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Text(
                        foro['titulo'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      // Badge de privacidad
                      BadgePrivacidad(privacidad: privacidad),

                      SizedBox(height: size.height * 0.01),

                      Text(
                        foro['descripcion'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      _InfoRow(
                        icon: Icons.person_outline,
                        texto: 'Creador: ${foro['creadorNombre'] ?? ''}',
                        cs: cs,
                        size: size,
                      ),

                      SizedBox(height: size.height * 0.008),

                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        texto:
                            'Creado: ${fecha.day}/${fecha.month}/${fecha.year}',
                        cs: cs,
                        size: size,
                      ),

                      // Botón cambiar privacidad — solo visible para el creador
                      if (esCreador) ...[
                        SizedBox(height: size.height * 0.018),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _cambiarPrivacidad(context, privacidad),
                          icon: Icon(
                            privacidad == 'privado'
                                ? Icons.public
                                : Icons.lock_outline,
                            size: size.width * 0.045,
                          ),
                          label: Text(
                            privacidad == 'privado'
                                ? 'Cambiar a Público'
                                : 'Cambiar a Privado',
                            style: TextStyle(fontSize: size.width * 0.038),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: privacidad == 'privado'
                                  ? cs.tertiary
                                  : cs.secondary,
                            ),
                            foregroundColor: privacidad == 'privado'
                                ? cs.tertiary
                                : cs.secondary,
                          ),
                        ),
                      ],

                      SizedBox(height: size.height * 0.025),

                      // Sección Rutas
                      _SeccionTitulo(texto: 'Rutas asociadas', cs: cs, size: size),

                      SizedBox(height: size.height * 0.01),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: cs.outlineVariant, width: 1),
                        ),
                        child: rutas.isEmpty
                            ? Text(
                                'Sin rutas asociadas',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              )
                            : Column(
                                children: rutas.map<Widget>((ruta) {
                                  return Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(
                                        bottom: size.height * 0.008),
                                    padding:
                                        EdgeInsets.all(size.width * 0.03),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: cs.outlineVariant, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.route_outlined,
                                          size: size.width * 0.04,
                                          color: cs.primary,
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Text(
                                          '${ruta['dia'] ?? ''} — ${ruta['ruta'] ?? ''}',
                                          style: TextStyle(
                                              color: cs.onSurface),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),

                      SizedBox(height: size.height * 0.025),

                      // Sección Miembros
                      _SeccionTitulo(
                          texto: 'Miembros (${miembros.length})',
                          cs: cs,
                          size: size),

                      SizedBox(height: size.height * 0.01),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: cs.outlineVariant, width: 1),
                        ),
                        child: Column(
                          children: miembros.map<Widget>((m) {
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  bottom: size.height * 0.008),
                              padding: EdgeInsets.all(size.width * 0.03),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: cs.outlineVariant, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: size.width * 0.04,
                                    color: cs.secondary,
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    m['nombre'] ?? 'Usuario',
                                    style: TextStyle(color: cs.onSurface),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),

            // Botones de acción
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.025,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _accionForo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                      child: Text(
                        esCreador ? 'Eliminar foro' : 'Salir del foro',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  final ColorScheme cs;
  final Size size;
  const _SeccionTitulo(
      {required this.texto, required this.cs, required this.size});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String texto;
  final ColorScheme cs;
  final Size size;
  const _InfoRow(
      {required this.icon,
      required this.texto,
      required this.cs,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: size.width * 0.04, color: cs.onSurfaceVariant),
        SizedBox(width: size.width * 0.02),
        Text(
          texto,
          style: TextStyle(
              fontSize: size.width * 0.038, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
