import 'package:flutter/material.dart';
import 'registro_ui_controlador.dart';
import 'registro_controlador.dart';
import 'icono_pantalla.dart';
import 'package:rutle_test/nucleo/rutas_app.dart';

class RegistroPantalla extends StatefulWidget {
  const RegistroPantalla({super.key});

  @override
  State<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends State<RegistroPantalla> {
  final ui = RegistroUIController();
  final backend = RegistroControlador();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      if (args != null) {
        _emailController.text = args['email'] ?? '';
        _passwordController.text = args['password'] ?? '';
        ui.email = _emailController.text;
        ui.password = _passwordController.text;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void seleccionarAvatar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IconoPantalla(avatarInicial: ui.avatarId),
      ),
    );

    if (result != null) {
      setState(() {
        ui.cambiarAvatar(result);
      });
    }
  }

  void registrar() async {
    String res = await backend.registrarUsuario(
      email: ui.email,
      password: ui.password,
      confirmPassword: ui.confirmPassword,
      nombreUsuario: ui.nombreUsuario,
      direccion: ui.direccion,
      colonia: ui.colonia,
      avatarId: ui.avatarId,
    );

    if (!mounted) return;

    if (res != "OK") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(res),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      RutasApp.verificacionCorreo,
      arguments: {
        "email": ui.email.trim(),
        "password": ui.password.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gap = SizedBox(height: size.height * 0.02);

    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.025,
        ),
        child: Column(
          children: [

            GestureDetector(
              onTap: seleccionarAvatar,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/avataaars/png?seed=${ui.avatarId}",
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  const Text("Toca para cambiar avatar"),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.03),

            TextField(
              controller: _emailController,
              onChanged: (v) => ui.email = v,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Correo electrónico",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            gap,
            TextField(
              controller: _passwordController,
              onChanged: (v) => ui.password = v,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            gap,
            TextField(
              onChanged: (v) => ui.confirmPassword = v,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar contraseña",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            gap,
            TextField(
              onChanged: (v) => ui.nombreUsuario = v,
              decoration: const InputDecoration(
                labelText: "Nombre de usuario",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            gap,
            TextField(
              onChanged: (v) => ui.direccion = v,
              decoration: const InputDecoration(
                labelText: "Dirección (Calle y número)",
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            gap,
            TextField(
              onChanged: (v) => ui.colonia = v,
              decoration: const InputDecoration(
                labelText: "Colonia",
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),

            SizedBox(height: size.height * 0.035),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registrar,
                child: const Text("Registrarse"),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿Ya tienes cuenta? "),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, RutasApp.login),
                  child: Text(
                    "Inicia sesión",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}