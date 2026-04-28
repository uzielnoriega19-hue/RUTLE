import 'package:flutter/material.dart';
import '../controladores/barra_semana_controlador.dart';

class BarraSemanaPantalla extends StatefulWidget {
  const BarraSemanaPantalla({super.key});

  @override
  State<BarraSemanaPantalla> createState() => _BarraSemanaPantallaState();
}

class _BarraSemanaPantallaState extends State<BarraSemanaPantalla> {
  void _navegar(String dia) async {
    final controlador = BarraSemanaControlador();
    DestinoSemana destino;

    switch (dia) {
      case 'L':
        destino = DestinoSemana.lunes;
        break;
      case 'M':
        destino = DestinoSemana.martes;
        break;
      case 'X':
        destino = DestinoSemana.miercoles;
        break;
      case 'J':
        destino = DestinoSemana.jueves;
        break;
      case 'V':
        destino = DestinoSemana.viernes;
        break;
      case 'S':
        destino = DestinoSemana.sabado;
        break;
      default:
        destino = DestinoSemana.domingo;
    }

    final ruta = await controlador.obtenerRuta(destino);

    if (!mounted) return;
    Navigator.pushNamed(context, ruta, arguments: destino);
  }

  void cancelar() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/forosPrincipal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    final double buttonSize = size.width * 0.18;
    final double spacing = size.width * 0.03;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.10),

              Text(
                'Selecciona el día que deseas configurar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // Separador decorativo
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.0),
                      cs.primary,
                      cs.primary.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Fila 1: Lu Ma Mi Ju
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DiaBoton(dia: 'Lu', size: buttonSize, onTap: () => _navegar('L')),
                  SizedBox(width: spacing),
                  DiaBoton(dia: 'Ma', size: buttonSize, onTap: () => _navegar('M')),
                  SizedBox(width: spacing),
                  DiaBoton(dia: 'Mi', size: buttonSize, onTap: () => _navegar('X')),
                  SizedBox(width: spacing),
                  DiaBoton(dia: 'Ju', size: buttonSize, onTap: () => _navegar('J')),
                ],
              ),

              SizedBox(height: size.height * 0.04),

              // Fila 2: Vi Sa Do (centrados)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DiaBoton(dia: 'Vi', size: buttonSize, onTap: () => _navegar('V')),
                  SizedBox(width: spacing),
                  DiaBoton(dia: 'Sa', size: buttonSize, onTap: () => _navegar('S')),
                  SizedBox(width: spacing),
                  DiaBoton(dia: 'Do', size: buttonSize, onTap: () => _navegar('D')),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: cancelar,
                  child: const Text('Cancelar'),
                ),
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class DiaBoton extends StatelessWidget {
  final String dia;
  final VoidCallback onTap;
  final double size;

  const DiaBoton({
    super.key,
    required this.dia,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          dia,
          style: TextStyle(
            fontSize: size * 0.30,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
