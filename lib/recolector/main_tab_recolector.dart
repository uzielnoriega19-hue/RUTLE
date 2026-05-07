import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:rutle_test/modulos/usuario/usuarios_pantalla.dart';
import 'chats/chats_recolector_pantalla.dart';
import 'ubicacion/ubicacion_pantalla.dart';

class MainTabRecolector extends StatefulWidget {
  const MainTabRecolector({super.key});

  @override
  State<MainTabRecolector> createState() => _MainTabRecolectorState();
}

class _MainTabRecolectorState extends State<MainTabRecolector> {
  DateTime? _ultimaPresion;
  int _indexActual = 1; // Empieza en el centro (Ubicación)
  bool _mostrarAviso = false;

  late PageController _pageController;
  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _pantallas = const [
      ChatsRecolectorPantalla(),   // 0 - izquierda
      UbicacionRecolectorPantalla(), // 1 - centro (principal)
      UsuarioPantalla(),            // 2 - derecha
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Widget _buildIcono(
    Widget Function(Color color, double size) iconBuilder,
    int index,
  ) {
    final height = MediaQuery.of(context).size.height;
    final isSelected = _indexActual == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final alpha = isSelected ? 1.0 : 0.5;
    final iconColor = baseColor.withValues(alpha: alpha);
    final iconSize = index == 1 ? height * 0.042 : height * 0.032;

    return GestureDetector(
      onTap: () => _cambiarPagina(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: height * 0.022,
          vertical: height * 0.008,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(height * 0.02),
        ),
        child: Transform.scale(
          scale: 1.2,
          child: iconBuilder(iconColor, iconSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_indexActual != 1) {
          _cambiarPagina(1);
          return;
        }
        final ahora = DateTime.now();
        if (_ultimaPresion == null ||
            ahora.difference(_ultimaPresion!) > const Duration(seconds: 2)) {
          _ultimaPresion = ahora;
          _mostrarAvisoSalir();
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ── Páginas ──────────────────────────────────────────
            PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _indexActual = i),
              children: _pantallas,
            ),

            // ── Aviso salir ───────────────────────────────────────
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
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app,
                          color: Colors.white, size: height * 0.025),
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

            // ── Barra de navegación ───────────────────────────────
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
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isDark
                          ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                          : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(ctx)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.45),
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
                      _buildIcono((c, s) => iconoir.ChatBubble(color: c, width: s, height: s), 0),
                      _buildIcono((c, s) => Icon(Icons.navigation_rounded, color: c, size: s), 1),
                      _buildIcono((c, s) => iconoir.User(color: c, width: s, height: s), 2),
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
