import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:rutle_test/admin/mapas/mapa_principal_pantalla.dart';
import 'package:rutle_test/admin/rutas/ruta_principal_pantalla.dart';
import 'package:rutle_test/admin/usuarios/pantallas/usuarios_principal_pantalla.dart';

class MainTabAdmin extends StatefulWidget {
  const MainTabAdmin({super.key});

  @override
  State<MainTabAdmin> createState() => _MainTabAdminState();
}

class _MainTabAdminState extends State<MainTabAdmin> {

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
      const _AdminVacioPantalla(label: 'Quejas'),
      const RutaPrincipalPantalla(),
      const MapasAdminPantalla(),
      const _AdminVacioPantalla(label: 'Mensajes'),
      const AdminPantalla(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.white : Colors.black;

    // 🔥 AQUÍ ESTÁ LA DIFERENCIA
    double alpha;

    if (index == 1) {
      // 👉 rutas más oscuro
      alpha = isSelected ? 1.0 : 0.7;
    } else {
      // 👉 los demás normal
      alpha = isSelected ? 1.0 : 0.5;
    }

    final iconColor = baseColor.withValues(alpha: alpha);

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
              ? baseColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(height * 0.02),
        ),
        child: IconTheme(
          data: IconThemeData(color: iconColor, size: iconSize),
          child: Transform.scale(
            scale: index == 1 ? 1.25 : 1.2, // 👉 ligeramente más grande rutas
            child: icono,
          ),
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
                      _buildIcono(const iconoir.WarningTriangle(), 0),
                      _buildIcono(const Icon(Icons.route), 1),
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

class _AdminVacioPantalla extends StatelessWidget {
  final String label;
  const _AdminVacioPantalla({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                  : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'En construcción',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}