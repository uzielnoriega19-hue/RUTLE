import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccionUsuarioPantalla extends StatefulWidget {
  final String nombre;
  final String uid;
  final String titulo;
  final String descripcion;

  const AccionUsuarioPantalla({
    super.key,
    required this.nombre,
    required this.uid,
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<AccionUsuarioPantalla> createState() => _AccionUsuarioPantallaState();
}

class _AccionUsuarioPantallaState extends State<AccionUsuarioPantalla> {
  String rolUsuario = 'Miembro';
  int reportes = 0;
  bool yaReportado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = FirebaseFirestore.instance;

    final query = await db
        .collection('foros')
        .where('titulo', isEqualTo: widget.titulo)
        .where('descripcion', isEqualTo: widget.descripcion)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final data = query.docs.first.data();

    // ROL
    if (data['creadorId'] == widget.uid) {
      rolUsuario = 'Admin';
    } else {
      final miembros = (data['miembros'] as List?) ?? [];

      for (var m in miembros) {
        if (m is Map && m['uid'] == widget.uid) {
          rolUsuario = (m['rol'] ?? 'miembro') == 'moderador'
              ? 'Moderador'
              : 'Miembro';
          break;
        }
      }
    }

    // REPORTES
    final userSnap = await db.collection('usuarios').doc(widget.uid).get();
    reportes = userSnap.data()?['reportes'] ?? 0;

    setState(() {});
  }

  Future<void> _reportarUsuario() async {
    if (yaReportado) return; 

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    // 🚫 BLOQUEO: no autorreporte
    if (currentUser.uid == widget.uid) return;

    final db = FirebaseFirestore.instance;

    await db.collection('usuarios').doc(widget.uid).set({
      'reportes': FieldValue.increment(1),
    }, SetOptions(merge: true));

    yaReportado = true;

    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

          Center(
            child: Container(
              width: size.width * 0.85,
              padding: EdgeInsets.all(size.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.white, // 🔥 fondo blanco
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black26,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NOMBRE + REPORTES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.nombre,
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reportes > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.warning, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$reportes',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ]
                    ],
                  ),

                  SizedBox(height: size.height * 0.01),

                  Text(
                    rolUsuario,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // BOTÓN REPORTAR (solo una vez)
                  ElevatedButton.icon(
                    onPressed: yaReportado ? null : _reportarUsuario,
                    icon: const Icon(Icons.flag),
                    label: const Text('Reportar'),
                  ),

                  SizedBox(height: size.height * 0.02),

                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}