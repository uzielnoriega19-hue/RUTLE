import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccionPoderPantalla extends StatefulWidget {
  final String nombre;
  final String uid;
  final String titulo;
  final String descripcion;

  const AccionPoderPantalla({
    super.key,
    required this.nombre,
    required this.uid,
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<AccionPoderPantalla> createState() => _AccionPoderPantallaState();
}

class _AccionPoderPantallaState extends State<AccionPoderPantalla> {
  String rol = 'miembro';
  int toques = 0;
  bool eliminado = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getForo() async {
    final db = FirebaseFirestore.instance;

    final query = await db
        .collection('foros')
        .where('titulo', isEqualTo: widget.titulo)
        .where('descripcion', isEqualTo: widget.descripcion)
        .limit(1)
        .get();

    return query.docs.first;
  }

  @override
  void initState() {
    super.initState();
    _verificarExistencia();
  }

  Future<void> _verificarExistencia() async {
    final doc = await _getForo();
    final data = doc.data();

    if (data == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final List miembros = (data['miembros'] as List?) ?? [];

    bool existe = false;

    for (final m in miembros) {
      if (m is Map && m['uid'] == widget.uid) {
        existe = true;
        setState(() {
          rol = (m['rol'] ?? 'miembro').toString();
          toques = (m['toques'] ?? 0) is int
              ? m['toques']
              : int.tryParse(m['toques'].toString()) ?? 0;
        });
        break;
      }
    }

    if (!existe) {
      setState(() => eliminado = true);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _darToque() async {
    final db = FirebaseFirestore.instance;
    final doc = await _getForo();

    final foroRef = doc.reference;
    final data = doc.data() ?? {};

    final List miembros = List.from(data['miembros'] ?? []);

    for (int i = 0; i < miembros.length; i++) {
      final m = miembros[i];

      if (m is Map && m['uid'] == widget.uid) {
        int actuales = (m['toques'] ?? 0) is int
            ? m['toques']
            : int.tryParse(m['toques'].toString()) ?? 0;

        int nuevos = actuales + 1;

        m['toques'] = nuevos;

        setState(() => toques = nuevos);

        if (nuevos == 1) {
          if (mounted) Navigator.pop(context);
        }

        if (nuevos >= 3) {
          miembros.removeWhere((e) =>
              e is Map && e['uid'] == widget.uid);

          final banned =
              List<String>.from(data['bannedUsers'] ?? []);

          if (!banned.contains(widget.uid)) {
            banned.add(widget.uid);
          }

          await foroRef.update({
            'miembros': miembros,
            'bannedUsers': banned,
          });

          await db.collection('chatforo').add({
            'titulo': widget.titulo,
            'descripcion': widget.descripcion,
            'mensaje':
                '${widget.nombre} fue expulsado por acumulación de toques',
            'tipo': 'sistema',
            'nombre': 'Sistema',
            'uid': '',
            'fecha': FieldValue.serverTimestamp(),
          });

          if (mounted) Navigator.pop(context);
          return;
        }

        await foroRef.update({'miembros': miembros});
        break;
      }
    }
  }

  Future<void> _toggleModerador() async {
    final doc = await _getForo();

    final foroRef = doc.reference;
    final data = doc.data() ?? {};

    final List miembros = List.from(data['miembros'] ?? []);

    for (final m in miembros) {
      if (m is Map && m['uid'] == widget.uid) {
        if (m['rol'] == 'moderador') {
          m['rol'] = 'miembro';
          setState(() => rol = 'miembro');
        } else {
          m['rol'] = 'moderador';
          setState(() => rol = 'moderador');
        }
      }
    }

    await foroRef.update({'miembros': miembros});
  }

  Future<void> _banearUsuario() async {
    final db = FirebaseFirestore.instance;
    final doc = await _getForo();

    final foroRef = doc.reference;
    final data = doc.data() ?? {};

    final List miembros = List.from(data['miembros'] ?? []);
    final List<String> banned =
        List<String>.from(data['bannedUsers'] ?? []);

    miembros.removeWhere((m) =>
        m is Map && m['uid'] == widget.uid);

    if (!banned.contains(widget.uid)) {
      banned.add(widget.uid);
    }

    await foroRef.update({
      'miembros': miembros,
      'bannedUsers': banned,
    });

    await db.collection('chatforo').add({
      'titulo': widget.titulo,
      'descripcion': widget.descripcion,
      'mensaje': '${widget.nombre} fue baneado del foro',
      'tipo': 'sistema',
      'nombre': 'Sistema',
      'uid': '',
      'fecha': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (eliminado) {
      return const Scaffold(
        body: Center(child: Text('Usuario no disponible')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: size.width * 0.85,
          padding: EdgeInsets.all(size.width * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Text(
                widget.nombre,
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Rol: ${rol.toUpperCase()}',
                style: TextStyle(fontSize: size.width * 0.04),
              ),
              Text(
                'Toques: $toques / 3',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              ElevatedButton(
                onPressed: _toggleModerador,
                child: Text(
                  rol == 'moderador'
                      ? 'Hacer usuario'
                      : 'Hacer moderador',
                ),
              ),
              SizedBox(height: size.height * 0.015),
              ElevatedButton(
                onPressed: _darToque,
                child: const Text('Dar un toque'),
              ),
              SizedBox(height: size.height * 0.015),
              ElevatedButton(
                onPressed: _banearUsuario,
                child: const Text('Banear'),
              ),
              SizedBox(height: size.height * 0.015),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}