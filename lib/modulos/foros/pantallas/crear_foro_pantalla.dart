import 'package:flutter/material.dart';
import '../controladores/crear_foro_controlador.dart';

class CrearForoPantalla extends StatefulWidget {
  const CrearForoPantalla({super.key});

  @override
  State<CrearForoPantalla> createState() => _CrearForoPantallaState();
}

class _CrearForoPantallaState extends State<CrearForoPantalla> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  final ForoControlador controlador = ForoControlador();

  String privacidad = 'privado';
  String? diaSeleccionado;

  Map<String, List<String>> rutasPorDia = {
    'Lunes': ['Ruta 1', 'Ruta 2'],
    'Martes': ['Ruta 3', 'Ruta 4'],
    'Miércoles': ['Ruta 5'],
    'Jueves': ['Ruta 6'],
    'Viernes': ['Ruta 7'],
    'Sábado': ['Ruta 8'],
    'Domingo': ['Ruta 9'],
  };

  List<Map<String, String>> rutasSeleccionadas = [];

  void agregarRuta(String ruta) {
    if (rutasSeleccionadas.length < 5 &&
        !rutasSeleccionadas.any((r) =>
            r['ruta'] == ruta && r['dia'] == diaSeleccionado)) {
      setState(() {
        rutasSeleccionadas.add({
          'dia': diaSeleccionado!,
          'ruta': ruta,
        });
        diaSeleccionado = null;
      });
    }
  }

  void eliminarRuta(Map<String, String> ruta) {
    setState(() {
      rutasSeleccionadas.remove(ruta);
    });
  }

  void mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje.replaceAll('Exception: ', '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void confirmarAccion(String tipo) {
    final pantallaContext = context;

    showDialog(
      context: pantallaContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text(
          tipo == 'crear'
              ? '¿Deseas crear el foro?'
              : '¿Deseas cancelar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (tipo == 'cancelar') {
                Navigator.pop(pantallaContext);
                return;
              }

              if (tituloController.text.trim().isEmpty) {
                mostrarError("Debes ingresar un título");
                return;
              }

              if (descripcionController.text.trim().isEmpty) {
                mostrarError("Debes ingresar una descripción");
                return;
              }

              if (rutasSeleccionadas.isEmpty) {
                mostrarError("Debes agregar al menos una ruta");
                return;
              }

              try {
                await controlador.crearForo(
                  titulo: tituloController.text,
                  descripcion: descripcionController.text,
                  privacidad: privacidad,
                  rutas: rutasSeleccionadas,
                );

                if (!mounted) return;

                Navigator.pop(pantallaContext);

              } catch (e) {
                if (!mounted) return;
                mostrarError(e.toString());
              }
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Foro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: height * 0.08,
                width: height * 0.08,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.group, size: 30),
              ),
            ),

            SizedBox(height: height * 0.02),

            const Text('Título de foro:'),
            TextField(
              controller: tituloController,
              maxLength: 40,
            ),

            SizedBox(height: height * 0.02),

            const Text('Descripción:'),
            TextField(
              controller: descripcionController,
              maxLength: 80,
              maxLines: 3,
            ),

            SizedBox(height: height * 0.02),

            const Text('Privacidad:'),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Privado'),
                    value: 'privado',
                    groupValue: privacidad,
                    onChanged: (value) {
                      setState(() => privacidad = value!);
                    },
                  ),
                  RadioListTile(
                    title: const Text('Público'),
                    value: 'publico',
                    groupValue: privacidad,
                    onChanged: (value) {
                      setState(() => privacidad = value!);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            const Text('Seleccionar días relacionadas con el foro'),
            DropdownButton<String>(
              value: diaSeleccionado,
              hint: const Text('Selecciona un día'),
              isExpanded: true,
              items: rutasPorDia.keys.map((dia) {
                return DropdownMenuItem(
                  value: dia,
                  child: Text(dia),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  diaSeleccionado = value;
                });
              },
            ),

            if (diaSeleccionado != null) ...[
              SizedBox(height: height * 0.02),
              const Text('Rutas disponibles:'),
              Column(
                children: rutasPorDia[diaSeleccionado]!
                    .map((ruta) => ListTile(
                          title: Text(ruta),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => agregarRuta(ruta),
                          ),
                        ))
                    .toList(),
              ),
            ],

            SizedBox(height: height * 0.02),

            const Text('Rutas seleccionadas (máx 5):'),
            Column(
              children: rutasSeleccionadas
                  .map((item) => ListTile(
                        title: Text('${item['ruta']} - ${item['dia']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => eliminarRuta(item),
                        ),
                      ))
                  .toList(),
            ),

            SizedBox(height: height * 0.1),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => confirmarAccion('cancelar'),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => confirmarAccion('crear'),
                  child: const Text('Crear Foro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}