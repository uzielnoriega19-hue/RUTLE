import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../usuario/usuario_controlador.dart';
import '../../nucleo/rutas_app.dart';
import '../../nucleo/tema_controlador.dart';
import '../../nucleo/widgets/boton_gradiente.dart';

class UsuarioPantalla extends StatefulWidget {
  const UsuarioPantalla({super.key});

  @override
  State<UsuarioPantalla> createState() => _UsuarioPantallaState();
}

class _UsuarioPantallaState extends State<UsuarioPantalla> {

  final UsuarioControlador controlador = UsuarioControlador();

  bool modoSeguro = true;
  bool cargando = true;

  bool intentoEdicion = false;
  bool animarError = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    controlador.limpiar();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final data = await controlador.cargarDatosUsuario();
    if (!mounted) return;
    if (data != null) controlador.aplicarDatos(data);
    setState(() => cargando = false);
  }

  void manejarIntentoEdicion() {
    if (!intentoEdicion) {
      setState(() {
        intentoEdicion = true;
        animarError = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          animarError = false;
        });
      });

    } else {
      mostrarAvisoEdicion();
    }
  }

  Widget sacudir(Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: animarError
          ? Matrix4.translationValues(8, 0, 0)
          : Matrix4.identity(),
      child: child,
    );
  }

  void mostrarAvisoEdicion() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Opción deshabilitada",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Para modificar tu información, presiona el botón \"Cambiar datos\".",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Entendido"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Seguro que deseas cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RutasApp.autenticacion,
                  (route) => false,
                );
              },
              child: const Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );
  }

  void mostrarMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final size = MediaQuery.of(context).size;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    width: size.width * 0.12,
                    height: size.height * 0.005,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Modo seguro",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: modoSeguro,
                        onChanged: (value) {
                          setModalState(() {});
                          setState(() {
                            modoSeguro = value;
                          });
                        },
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Modo oscuro",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: context.read<TemaControlador>().esOscuroEfectivo(context),
                        onChanged: (value) {
                          context.read<TemaControlador>().setModo(value);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.02),

                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration decoracionCampo(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: animarError ? Colors.red : Colors.grey,
        ),
      ),
    );
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
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                      : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            );
          },
        ),
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: mostrarMenu,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            children: [

              SizedBox(height: size.height * 0.04),

              GestureDetector(
                onTap: manejarIntentoEdicion,
                child: sacudir(
                  CircleAvatar(
                    radius: size.width * 0.18,
                    backgroundColor: animarError ? Colors.red.shade100 : null,
                    backgroundImage: controlador.fotoUrl.isNotEmpty
                        ? NetworkImage(controlador.fotoUrl)
                        : null,
                    child: controlador.fotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              sacudir(
                TextField(
                  controller: controlador.nombreUsuarioController,
                  readOnly: true,
                  onTap: manejarIntentoEdicion,
                  decoration: decoracionCampo("Nombre de usuario"),
                ),
              ),

              const SizedBox(height: 20),

              sacudir(
                TextField(
                  controller: controlador.correoController,
                  readOnly: true,
                  onTap: manejarIntentoEdicion,
                  decoration: decoracionCampo("Correo"),
                ),
              ),

              const SizedBox(height: 20),

              sacudir(
                TextField(
                  controller: controlador.direccionController,
                  readOnly: true,
                  onTap: manejarIntentoEdicion,
                  decoration: decoracionCampo("Dirección de casa"),
                ),
              ),

              const SizedBox(height: 30),

              BotonGradiente(
                texto: "Cambiar datos",
                ancho: double.infinity,
                onPressed: () async {
                  final actualizado = await Navigator.pushNamed(
                    context,
                    RutasApp.editarPerfilPantalla,
                  );
                  if (actualizado == true) {
                    await cargarDatos();
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: mostrarDialogoCerrarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text("Cerrar sesión"),
                ),
              ),

              SizedBox(height: size.height * 0.04),

            ],
          ),
        ),
      ),
    );
  }
}