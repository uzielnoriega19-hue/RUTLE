import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:rutle_test/modulos/principal/principal_pantalla.dart';
import 'package:rutle_test/modulos/usuario/usuarios_pantalla.dart';
import 'package:rutle_test/modulos/recordatorios/pantallas/recordatorios_pantalla.dart';
import 'package:rutle_test/modulos/chatbot/chatbot_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/foros_principal_pantalla.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {

  DateTime? _ultimaPresion;
  int _indexActual = 2;
  bool _mostrarAviso = false;

  late PageController _pageController;
  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 2);

    _pantallas = [
      const ChatbotPantalla(),
      const RecordatoriosPantalla(),
      const PrincipalPantalla(),
      const ForosPrincipalPantalla(),
      const UsuarioPantalla(),
    ];
  }

  Future<bool> _manejarBack() async {
    if (_indexActual != 2) {
      _pageController.jumpToPage(2);
      setState(() => _indexActual = 2);
      return false;
    }

    final ahora = DateTime.now();

    if (_ultimaPresion == null ||
        ahora.difference(_ultimaPresion!) > const Duration(seconds: 2)) {
      _ultimaPresion = ahora;
      _mostrarAvisoSalir();
      return false;
    }

    return true;
  }

  void _mostrarAvisoSalir() {
    setState(() => _mostrarAviso = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _mostrarAviso = false);
    });
  }

  void _cambiarPagina(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );

    setState(() => _indexActual = index);
  }

  Widget _buildIcono(Widget icono, int index) {
    final height = MediaQuery.of(context).size.height;
    final isSelected = _indexActual == index;
    // Siempre blanco sobre el gradiente (teal/azul en claro, azul oscuro en oscuro)
    final iconColor = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.58);
    final iconSize = index == 2 ? height * 0.040 : height * 0.032;

    return GestureDetector(
      onTap: () => _cambiarPagina(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: height * 0.018,
          vertical: height * 0.008,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(height * 0.02),
        ),
        child: IconTheme(
          data: IconThemeData(color: iconColor, size: iconSize),
          child: Transform.scale(scale: 1.2, child: icono),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: _manejarBack,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [

            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _indexActual = index);
              },
              children: _pantallas,
            ),

            Positioned(
              top: topPadding + height * 0.015,
              left: width * 0.08,
              right: width * 0.08,
              child: AnimatedOpacity(
                opacity: _mostrarAviso ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.016,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(height * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: height * 0.025,
                      ),
                      SizedBox(width: width * 0.03),
                      Text(
                        'Pulsa de nuevo para salir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.018,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: height * 0.03,
              right: height * 0.03,
              bottom: height * 0.02,
              child: Builder(builder: (ctx) {
                final isDark = Theme.of(ctx).brightness == Brightness.dark;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: height * 0.006),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.025),
                    // Mismo gradiente que la barra de semana, sin blur
                    // Mismo gradiente que semana de recolección en ambos modos
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isDark
                          ? const [Color.fromARGB(255, 28, 63, 113), Color.fromARGB(255, 27, 120, 201)]
                          : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIcono(const iconoir.WarningTriangle(), 0),
                      _buildIcono(const iconoir.Bell(), 1),
                      _buildIcono(const iconoir.Map(), 2),
                      _buildIcono(const iconoir.ChatBubble(), 3),
                      _buildIcono(const iconoir.User(), 4),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}