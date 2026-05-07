import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rutle_test/admin/mapas/mapa_quejas_pantalla.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';

// Centro de Guadalajara
const _gdl = LatLng(20.6736, -103.3440);

class MapasAdminPantalla extends StatefulWidget {
  const MapasAdminPantalla({super.key});

  @override
  State<MapasAdminPantalla> createState() => _MapasAdminPantallaState();
}

class _MapasAdminPantallaState extends State<MapasAdminPantalla> {
  int _tabSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Mapas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // Selector de mapa con más espacio arriba
          Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.05,
              height * 0.03,
              width * 0.05,
              height * 0.018,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BotonTab(
                    texto: 'Recolección',
                    seleccionado: _tabSeleccionado == 0,
                    gradientColors: gradientColors,
                    isDark: isDark,
                    onTap: () => setState(() => _tabSeleccionado = 0),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _BotonTab(
                    texto: 'Quejas',
                    seleccionado: _tabSeleccionado == 1,
                    gradientColors: gradientColors,
                    isDark: isDark,
                    onTap: () => setState(() => _tabSeleccionado = 1),
                  ),
                ),
              ],
            ),
          ),

          // Mapa con márgenes y bordes redondeados (no ocupa toda la pantalla)
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.04,
                0,
                width * 0.04,
                height * 0.13,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _tabSeleccionado == 0
                      ? const MapaWidget(
                          key: ValueKey('recoleccion'),
                          centroFijo: _gdl,
                          zoom: 12,
                          mostrarCasa: false,
                        )
                      : const MapaQuejasPantalla(key: ValueKey('quejas')),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _BotonTab extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final List<Color> gradientColors;
  final bool isDark;
  final VoidCallback onTap;

  const _BotonTab({
    required this.texto,
    required this.seleccionado,
    required this.gradientColors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (seleccionado) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SizedBox(
            height: height * 0.055,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height * 0.055,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
