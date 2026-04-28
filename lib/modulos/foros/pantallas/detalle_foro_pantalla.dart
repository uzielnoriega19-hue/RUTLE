import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutle_test/modulos/foros/widgets/badge_privacidad.dart';

class DetalleForoPantalla extends StatelessWidget {
  final Map<String, dynamic> foro;

  const DetalleForoPantalla({super.key, required this.foro});

  Future<void> unirseAlForo(String foroId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;

    final userDoc = await db.collection('usuarios').doc(user.uid).get();
    final nombreUsuario = userDoc.data()?['nombreUsuario'] ?? 'Usuario';

    final nuevoMiembro = {
      'uid': user.uid,
      'nombre': nombreUsuario,
    };

    final foroRef = db.collection('foros').doc(foroId);

    final foroSnap = await foroRef.get();
    final data = foroSnap.data();

    final miembros = (data?['miembros'] as List?) ?? [];

    final yaExiste = miembros.any((m) => m['uid'] == user.uid);
    if (yaExiste) return;

    await foroRef.update({
      'miembros': FieldValue.arrayUnion([nuevoMiembro]),
    });

    await FirebaseFirestore.instance.collection('chatforo').add({
      'titulo': data?['titulo'],
      'descripcion': data?['descripcion'],
      'mensaje': '$nombreUsuario entró al foro',
      'tipo': 'sistema',
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _confirmarUnion(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
          title: const Text('Unirse al foro'),
          content: const Text('¿Estás seguro de que deseas unirte a este foro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    return resultado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('foros')
                    .doc(foro['id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  final user = FirebaseAuth.instance.currentUser;
                  final banned = (data['bannedUsers'] as List?) ?? [];

                  final estaBaneado =
                      user != null && banned.contains(user.uid);

                  // 🔴 BLOQUEO TOTAL SI ESTÁ BANEADO
                  if (estaBaneado) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No tienes acceso a este foro',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Regresar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final miembros = (data['miembros'] as List?) ?? [];
                  final rutas = (data['rutas'] as List?) ?? [];
                  final fecha =
                      (data['fechaCreacion'] as Timestamp).toDate();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.02),

                          Container(
                            width: size.width * 0.3,
                            height: size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.forum,
                                size: size.width * 0.15),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Text(
                            data['titulo'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: size.height * 0.01),

                          BadgePrivacidad(
                            privacidad: data['privacidad'] ?? 'publico',
                          ),

                          SizedBox(height: size.height * 0.01),

                          Text(data['descripcion'] ?? ''),

                          SizedBox(height: size.height * 0.02),

                          Text('Creador: ${data['creadorNombre'] ?? ''}'),

                          SizedBox(height: size.height * 0.01),

                          Text(
                            'Creado: ${fecha.day}/${fecha.month}/${fecha.year}',
                          ),

                          SizedBox(height: size.height * 0.02),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Rutas asociadas:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(height: size.height * 0.01),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(size.width * 0.03),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: rutas.map<Widget>((ruta) {
                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      bottom: size.height * 0.008),
                                  padding: EdgeInsets.all(size.width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${ruta['dia'] ?? ''} - ${ruta['ruta'] ?? ''}',
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Miembros:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(height: size.height * 0.01),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(size.width * 0.03),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: miembros.map<Widget>((m) {
                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      bottom: size.height * 0.008),
                                  padding: EdgeInsets.all(size.width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(m['nombre'] ?? 'Usuario'),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botones de acción según estado del usuario
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('foros')
                  .doc(foro['id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final user = FirebaseAuth.instance.currentUser;
                final banned = (data['bannedUsers'] as List?) ?? [];

                if (user != null && banned.contains(user.uid)) {
                  return const SizedBox();
                }

                final miembros = (data['miembros'] as List?) ?? [];
                final esCreador = user?.uid == data['creadorId'];
                final esMiembro = miembros.any(
                  (m) => m is Map && m['uid'] == user?.uid,
                );
                final esPrivado =
                    (data['privacidad'] ?? 'publico') == 'privado';

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
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
                        child: esMiembro || esCreador
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/chatForo',
                                    arguments: {
                                      'titulo': data['titulo'],
                                      'descripcion': data['descripcion'],
                                    },
                                  );
                                },
                                child: const Text('Entrar al chat'),
                              )
                            : ElevatedButton(
                                onPressed: esPrivado
                                    ? null
                                    : () async {
                                        final confirmar =
                                            await _confirmarUnion(context);
                                        if (!confirmar) return;
                                        await unirseAlForo(foro['id']);
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                      },
                                child: Text(
                                  esPrivado ? 'Foro privado' : 'Unirse',
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}