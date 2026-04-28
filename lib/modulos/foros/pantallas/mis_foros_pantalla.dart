import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MisForosPantalla extends StatelessWidget {
  const MisForosPantalla({super.key});

  Stream<List<Map<String, dynamic>>> obtenerMisForos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('foros')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id, 
              })
          .where((foro) {
            final miembros = foro['miembros'] as List?;

            if (miembros == null) return false;

            return miembros.any((miembro) {
              return miembro['uid'] == uid;
            });
          })
          .toList();
    });
  }

  void volver(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/forosPrincipal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis foros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => volver(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: obtenerMisForos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final foros = snapshot.data!;

                    if (foros.isEmpty) {
                      return const Center(
                        child: Text('No estás en ningún foro'),
                      );
                    }

                    return ListView.builder(
                      itemCount: foros.length,
                      itemBuilder: (context, index) {
                        final foro = foros[index];

                        final miembros =
                            (foro['miembros'] as List?)?.length ?? 0;
                        final fechaRaw = foro['fechaCreacion'];
                        final fecha = fechaRaw is Timestamp
                            ? fechaRaw.toDate()
                            : DateTime.now();

                        final cs = Theme.of(context).colorScheme;

                        return Container(
                          margin: EdgeInsets.only(bottom: size.height * 0.015),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.tertiary.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/chatForo',
                                arguments: {
                                  'titulo': foro['titulo'],
                                  'descripcion': foro['descripcion'],
                                },
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    // Borde izquierdo terciario (teal) para diferenciar de "buscar foros"
                                    Container(
                                      width: 4,
                                      color: cs.tertiary,
                                    ),
                                    Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(size.width * 0.04),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width * 0.14,
                                            height: size.width * 0.14,
                                            decoration: BoxDecoration(
                                              color: cs.tertiaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.forum_rounded,
                                              size: size.width * 0.07,
                                              color: cs.onTertiaryContainer,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.04),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  foro['titulo'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: size.width * 0.042,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.onSurface,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.006),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.group_outlined,
                                                      size: size.width * 0.035,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    Text(
                                                      '$miembros miembros',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.width * 0.033,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.004),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today_outlined,
                                                      size: size.width * 0.033,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    Text(
                                                      '${fecha.day}/${fecha.month}/${fecha.year}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.width * 0.033,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ),  // cierra Expanded
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: size.height * 0.02),
              
            ],
          ),
        ),
      ),
    );
  }
}