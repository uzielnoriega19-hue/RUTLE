import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:rutle_test/admin/mapas/mapa_principal_pantalla.dart';

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
      //const QuejasLista(),      
      //const RutasLista(),         
      const MapasAdminPantalla(),      
      //const MensajesDashboard(),  
      //const UsuariosLista(),
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

    return IconButton(
      iconSize: index == 2 ? height * 0.040 : height * 0.032,
      icon: IconTheme(
        data: IconThemeData(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          size: index == 2 ? height * 0.040 : height * 0.032,
        ),
        child: Transform.scale(
          scale: 1.2,
          child: icono,
        ),
      ),
      onPressed: () => _cambiarPagina(index),
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

            /// 📄 Páginas
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _indexActual = index);
              },
              children: _pantallas,
            ),

            /// ⚠️ aviso salir
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
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(height * 0.02),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app,
                          color: Colors.white,
                          size: height * 0.025),
                      SizedBox(width: width * 0.03),
                      Text(
                        'Pulsa de nuevo para salir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.018,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🧭 NAV BAR
            Positioned(
              left: 0,
              right: 0,
              bottom: height * 0.02,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: height * 0.03),
                padding: EdgeInsets.symmetric(vertical: height * 0.006),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(height * 0.02),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}