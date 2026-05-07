import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/rutas_app.dart';
import '../../../nucleo/tema_controlador.dart';
import '../../../nucleo/widgets/boton_gradiente.dart';
import 'crear_admin_recolector_pantalla.dart';
import 'lista_usuarios_pantalla.dart';

class AdminPantalla extends StatefulWidget {
  const AdminPantalla({super.key});

  @override
  State<AdminPantalla> createState() => _AdminPantallaState();
}

class _AdminPantallaState extends State<AdminPantalla> {

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

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final tema = context.read<TemaControlador>();
    final esOscuro = tema.esOscuroEfectivo(context);

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
          "Admin",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,

        // 🌙☀️ BOTÓN DE TEMA (único en actions)
        actions: [
          IconButton(
            icon: Icon(
              esOscuro ? Icons.light_mode : Icons.dark_mode,
              color: esOscuro ? Colors.white : Colors.black,
              size: 26,
            ),
            onPressed: () {
              tema.setModo(!esOscuro);
              setState(() {});
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔧 BOTÓN CREAR ADMIN / RECOLECTOR
            SizedBox(
              width: double.infinity,
              child: BotonGradiente(
                texto: "Crear admin o recolector",
                ancho: double.infinity,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrearAdminRecolectorPantalla(),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // 👥 BOTÓN VER USUARIOS
            SizedBox(
              width: double.infinity,
              child: BotonGradiente(
                texto: "Ver usuarios",
                ancho: double.infinity,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListaUsuariosPantalla(),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // 🔴 BOTÓN CERRAR SESIÓN (más gordito)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mostrarDialogoCerrarSesion,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.022,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}