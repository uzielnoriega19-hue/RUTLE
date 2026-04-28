import 'package:flutter/material.dart';
import '../controladores/barra_semana_controlador.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';

class SeleccionarDiaPantalla extends StatefulWidget {
  final DestinoSemana dia;

  const SeleccionarDiaPantalla({super.key, required this.dia});

  @override
  State<SeleccionarDiaPantalla> createState() => _SeleccionarDiaPantallaState();
}

class _SeleccionarDiaPantallaState extends State<SeleccionarDiaPantalla> {
  int? rutaSeleccionada;

  String _nombreDia(DestinoSemana dia) {
    switch (dia) {
      case DestinoSemana.lunes:
        return "Lunes";
      case DestinoSemana.martes:
        return "Martes";
      case DestinoSemana.miercoles:
        return "Miércoles";
      case DestinoSemana.jueves:
        return "Jueves";
      case DestinoSemana.viernes:
        return "Viernes";
      case DestinoSemana.sabado:
        return "Sábado";
      case DestinoSemana.domingo:
        return "Domingo";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final nombreDia = _nombreDia(widget.dia);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: size.height * 0.06),

              Text(
                "Rutas disponibles - $nombreDia",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),

              SizedBox(height: size.height * 0.05),

              _rutaItem(1, "Azul"),
              _rutaItem(2, "Rojo"),
              _rutaItem(3, "Verde"),

              SizedBox(height: size.height * 0.025),

              Container(
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: const MapaWidget(
                  zoom: 14.25,
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: cs.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancelar"),
                    ),
                  ),

                  SizedBox(width: size.width * 0.05),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                      ),
                      onPressed: rutaSeleccionada == null
                          ? null
                          : () {
                              // lógica aquí
                            },
                      child: const Text("Guardar"),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rutaItem(int numero, String colorNombre) {
    final cs = Theme.of(context).colorScheme;
    final seleccionado = rutaSeleccionada == numero;

    Color colorRuta;
    switch (numero) {
      case 1:
        colorRuta = Colors.blue;
        break;
      case 2:
        colorRuta = Colors.red;
        break;
      case 3:
        colorRuta = Colors.green;
        break;
      default:
        colorRuta = cs.primary;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          rutaSeleccionada = numero;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: seleccionado ? cs.primaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado
                ? cs.primary
                : cs.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              seleccionado
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: seleccionado ? cs.primary : cs.outline,
            ),

            SizedBox(width: 12),

            Text(
              'Ruta $numero',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorRuta,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  colorNombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorRuta,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}