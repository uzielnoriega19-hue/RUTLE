import 'package:flutter/material.dart';
import 'package:rutle_test/admin/mapas/mapa_quejas_pantalla.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';

class MapasAdminPantalla extends StatefulWidget {
  const MapasAdminPantalla({super.key});

  @override
  State<MapasAdminPantalla> createState() => _MapasAdminPantallaState();
}

class _MapasAdminPantallaState extends State<MapasAdminPantalla> {

  int _tabSeleccionado = 0; 

  void _cambiarTab(int index) {
    setState(() {
      _tabSeleccionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [

          Container(
            padding: EdgeInsets.only(
              top: height * 0.06,
              left: width * 0.05,
              right: width * 0.05,
              bottom: height * 0.02,
            ),
            child: Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () => _cambiarTab(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      decoration: BoxDecoration(
                        color: _tabSeleccionado == 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Rutas",
                          style: TextStyle(
                            color: _tabSeleccionado == 0
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: width * 0.03),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _cambiarTab(1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      decoration: BoxDecoration(
                        color: _tabSeleccionado == 1
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Quejas",
                          style: TextStyle(
                            color: _tabSeleccionado == 1
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tabSeleccionado == 0
                  ? const MapaWidget() 
                  : const MapaQuejasPantalla(),
            ),
          ),
        ],
      ),
    );
  }
}