import 'package:flutter/material.dart';

class MapaQuejasPantalla extends StatelessWidget {
  const MapaQuejasPantalla({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.orange,
            ),

            SizedBox(height: 10),

            Text(
              "Mapa de Quejas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              "Aquí se mostrarán quejas por colonia",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}