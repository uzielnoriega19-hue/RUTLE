import 'package:flutter/material.dart';
import 'package:rutle_test/nucleo/rutas_app.dart';
import 'package:rutle_test/nucleo/widgets/boton_gradiente.dart';
import '../controladores/recordatorios_controlador.dart';
import 'editar_recordatorio_pantalla.dart';

class RecordatoriosPantalla extends StatefulWidget {
  const RecordatoriosPantalla({super.key});

  @override
  State<RecordatoriosPantalla> createState() => _RecordatoriosPantallaState();
}

class _RecordatoriosPantallaState extends State<RecordatoriosPantalla> {
  final controlador = RecordatoriosControlador();

  bool modoEliminar = false;
  List<String> seleccionados = [];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Recordatorios")),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StreamBuilder(
                  stream: controlador.obtenerRecordatoriosDesdeUno(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No hay recordatorios"));
                    }
                    final recordatorios = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.all(width * 0.03),
                      itemCount: recordatorios.length,
                      itemBuilder: (context, index) {
                        final r = recordatorios[index];
                        final id = r["id"];
                        return Card(
                          margin: EdgeInsets.only(bottom: height * 0.015),
                          child: ListTile(
                            onTap: () {
                              if (modoEliminar) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarRecordatorioPantalla(
                                    idRecordatorioDoc: id,
                                  ),
                                ),
                              );
                            },
                            leading: modoEliminar
                                ? Checkbox(
                                    value: seleccionados.contains(id),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          seleccionados.add(id);
                                        } else {
                                          seleccionados.remove(id);
                                        }
                                      });
                                    },
                                  )
                                : CircleAvatar(
                                    child: Text(
                                      r["idRecordatorio"].toString(),
                                    ),
                                  ),
                            title: Text(r["titulo"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (r["descripcion"] != "")
                                  Text(r["descripcion"]),

                                SizedBox(height: height * 0.005),

                                Text(
                                  "Notificación ${r["recordatorioAntes"]} min antes",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  r["lugar"],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: height * 0.02),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text(modoEliminar ? "Confirmar" : "Eliminar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () async {
                      if (!modoEliminar) {
                        setState(() {
                          modoEliminar = true;
                        });
                        return;
                      }
                      if (seleccionados.isEmpty) {
                        setState(() {
                          modoEliminar = false;
                        });
                        return;
                      }
                      final confirmar = await showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text("Eliminar recordatorios"),
                            content: const Text("¿Estás seguro de eliminarlos?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("Cancelar"),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Eliminar"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmar == true) {
                        for (var id in seleccionados) {
                          await controlador.eliminarRecordatorio(id);
                        }

                        setState(() {
                          seleccionados.clear();
                          modoEliminar = false;
                        });
                      }
                    },
                  ),
                ),

                SizedBox(width: width * 0.04),

                Expanded(
                  child: BotonGradiente(
                    texto: "Agregar",
                    iconoWidget: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RutasApp.agregarRecordatorio,
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.12),

          ],
        ),
      ),
    );
  }
}
