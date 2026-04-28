import 'package:flutter/material.dart';

class FiltrosForoPantalla extends StatefulWidget {
  const FiltrosForoPantalla({super.key});

  @override
  State<FiltrosForoPantalla> createState() => _FiltrosForoPantallaState();
}

class _FiltrosForoPantallaState extends State<FiltrosForoPantalla> {
  String privacidad = 'todos';

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  final List<String> rutas = [
    'Ruta 1',
    'Ruta 2',
    'Ruta 3',
    'Ruta 4',
  ];

  final List<String> rutasSeleccionadas = [];

  Widget _textoDialogo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Future<void> _mostrarError(String mensaje) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Falta información'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarAplicar() async {
    if (privacidad.isEmpty) {
      await _mostrarError('Selecciona la privacidad');
      return;
    }

    if (rutasSeleccionadas.isEmpty) {
      await _mostrarError('Selecciona al menos una ruta');
      return;
    }

    int? min;
    int? max;

    if (minController.text.trim().isNotEmpty) {
      min = int.tryParse(minController.text.trim());
      if (min == null) {
        await _mostrarError('El mínimo no es válido');
        return;
      }
    }

    if (maxController.text.trim().isNotEmpty) {
      max = int.tryParse(maxController.text.trim());
      if (max == null) {
        await _mostrarError('El máximo no es válido');
        return;
      }
    }

    final confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aplicar filtros'),
        content: _textoDialogo('¿Deseas aplicar los filtros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      Navigator.pop(context, {
        'privacidad': privacidad,
        'min': min,
        'max': max,
        'rutas': rutasSeleccionadas,
      });
    }
  }

  Future<void> _confirmarCancelar() async {
    final confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar'),
        content: _textoDialogo('¿Deseas salir sin aplicar filtros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),

                Text(
                  'Privacidad',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                Column(
                  children: [
                    RadioListTile(
                      title: const Text('Todos'),
                      value: 'todos',
                      groupValue: privacidad,
                      onChanged: (value) {
                        setState(() {
                          privacidad = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('Público'),
                      value: 'publico',
                      groupValue: privacidad,
                      onChanged: (value) {
                        setState(() {
                          privacidad = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('Privado'),
                      value: 'privado',
                      groupValue: privacidad,
                      onChanged: (value) {
                        setState(() {
                          privacidad = value.toString();
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),

                Text(
                  'Rango de miembros',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Máximo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),

                Text(
                  'Rutas asociadas',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rutas.length,
                  itemBuilder: (context, index) {
                    final ruta = rutas[index];
                    final seleccionada = rutasSeleccionadas.contains(ruta);

                    return CheckboxListTile(
                      title: Text(ruta),
                      value: seleccionada,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            rutasSeleccionadas.add(ruta);
                          } else {
                            rutasSeleccionadas.remove(ruta);
                          }
                        });
                      },
                    );
                  },
                ),

                SizedBox(height: size.height * 0.02),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _confirmarCancelar,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmarAplicar,
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}