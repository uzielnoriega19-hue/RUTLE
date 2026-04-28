import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutle_test/modulos/autenticacion/login/login_controlador.dart';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final LoginControlador _controlador = LoginControlador();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
 
  bool _ocultarPassword = true;

  Future<void> _mostrarRecuperarContrasena() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.pop(ctx);

              if (email.isEmpty) return;

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correo de recuperación enviado. Revisa tu bandeja.'),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                final msg = switch (e.code) {
                  'user-not-found' => 'No existe una cuenta con ese correo.',
                  'invalid-email'  => 'El formato del correo no es válido.',
                  _                => 'Error: ${e.message}',
                };
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize :size.width * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(flex: 1),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: size.width * 0.04),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.02,
                    horizontal: size.width * 0.04,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                style: TextStyle(fontSize: size.width * 0.04),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.02,
                    horizontal: size.width * 0.04,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                      size: size.width * 0.07,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPassword = !_ocultarPassword;
                      });
                    },
                  ),
                ),
              ),

              const Spacer(flex: 2),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final resultado = await _controlador.iniciarSesion(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    if (!mounted) return;

                    if (resultado == '/mainTab') {
                      Navigator.pushNamedAndRemoveUntil(
                        context, '/mainTab',
                        (route) => false,
                      );
                    } else if (resultado == '/verificacion') {
                      Navigator.pushNamed(context, '/verificacion');
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(resultado),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: size.width * 0.045),
                  ),
                ),
              ),

              const Spacer(flex: 1),
              
              TextButton(
                onPressed: _mostrarRecuperarContrasena,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(fontSize: size.width * 0.04),
                  ),
                  GestureDetector(
                    onTap: () async{
                      final ruta = await _controlador.obtenerRuta(DestinoLogin.registro);
                      if (!mounted) return;
                      Navigator.pushNamed(context, ruta);
                    },
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),
              
            ]
          ),
        ),
      ),
    );
  }
}