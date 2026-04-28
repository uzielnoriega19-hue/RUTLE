import 'package:flutter/material.dart';
import 'editar_perfil_controlador.dart';
import '../autenticacion/registro/icono_pantalla.dart';

class EditarPerfilPantalla extends StatefulWidget {
  const EditarPerfilPantalla({super.key});

  @override
  State<EditarPerfilPantalla> createState() => _EditarPerfilPantallaState();
}

class _EditarPerfilPantallaState extends State<EditarPerfilPantalla> {
  final controlador = EditarPerfilControlador();
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    controlador.limpiar();
    super.dispose();
  }

  Future<void> cargar() async {
    await controlador.cargarDatos();
    setState(() {
      cargando = false;
    });
  }

  Future<void> confirmarGuardar() async {
    final res = await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Guardar cambios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("¿Deseas guardar los cambios?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Aceptar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (res == true) {
      await controlador.guardarCambios();
      if (!mounted) return;

      Navigator.pop(context, true); 
    }
  }

  Future<void> confirmarDescartar() async {
    final res = await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Descartar cambios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("¿Salir sin guardar cambios?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Aceptar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (res == true) {
      if (!mounted) return;
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.08,
              right: size.width * 0.08,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                SizedBox(height: size.height * 0.04),

                GestureDetector(
                  onTap: () async {
                    final nuevoAvatar = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IconoPantalla(
                          avatarInicial: controlador.avatarId,
                        ),
                      ),
                    );

                    if (nuevoAvatar != null) {
                      setState(() {
                        controlador.setAvatar(nuevoAvatar);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: size.width * 0.18,
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: ClipOval(
                        child: controlador.fotoUrl.isNotEmpty
                            ? Image.network(
                                controlador.fotoUrl,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                Icons.person,
                                size: size.width * 0.12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                TextField(
                  controller: controlador.nombreUsuarioController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de usuario",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: size.height * 0.025),

                TextField(
                  controller: controlador.direccionController,
                  decoration: const InputDecoration(
                    labelText: "Dirección",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: confirmarGuardar,
                    child: const Text("Guardar cambios"),
                  ),
                ),

                SizedBox(height: size.height * 0.015),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: confirmarDescartar,
                    child: const Text("Descartar cambios"),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

              ],
            ),
          ),
        ),
      ),
    );
  }
}