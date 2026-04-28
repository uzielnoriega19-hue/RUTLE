import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'nucleo/rutas_app.dart';
import 'nucleo/tema_app.dart';
import 'nucleo/tema_controlador.dart';
import 'modulos/chatbot/chatbot_controlador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cargar preferencia de tema antes de mostrar la app
  final temaControlador = TemaControlador();
  await temaControlador.cargar();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: temaControlador),
        ChangeNotifierProvider(create: (_) => ChatbotControlador()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final temaControlador = context.watch<TemaControlador>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUTLE',
      theme: TemaApp.temaClaro,
      darkTheme: TemaApp.temaOscuro,
      themeMode: temaControlador.modo,
      initialRoute: RutasApp.splash,
      onGenerateRoute: RutasApp.onGenerateRoute,
    );
  }
}
