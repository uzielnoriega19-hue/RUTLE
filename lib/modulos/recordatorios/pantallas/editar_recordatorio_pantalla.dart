import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';
import '../controladores/editar_recordatorio_controlador.dart';

class EditarRecordatorioPantalla extends StatefulWidget {
  final String idRecordatorioDoc;
  const EditarRecordatorioPantalla({
    super.key,
    required this.idRecordatorioDoc,
  });

  @override
  State<EditarRecordatorioPantalla> createState() =>
      _EditarRecordatorioPantallaState();
}

class _EditarRecordatorioPantallaState
    extends State<EditarRecordatorioPantalla> {
  final controlador = EditarRecordatorioControlador();
  final _formKey = GlobalKey<FormState>();

  String? diaSeleccionado;
  String? rutaSeleccionada;
  int? minutosAntes;

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  bool cargando = true;

  final dias = [
    "Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"
  ];

  final rutas = [
    "Ruta 1",
    "Ruta 2",
    "Ruta 3"
  ];

  final tiempos = [5,10,15,30,60];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {

    final data = await controlador.obtenerRecordatorio(
      widget.idRecordatorioDoc,
    );

    if(data != null){

      tituloController.text = data["titulo"] ?? "";
      descripcionController.text = data["descripcion"] ?? "";
      minutosAntes = data["recordatorioAntes"];
      diaSeleccionado = data["dia"];
      rutaSeleccionada = data["ruta"];
    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    if(cargando){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Recordatorio"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  SizedBox(height: height * 0.03),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Selecciona el día",
                      border: OutlineInputBorder(),
                    ),
                    value: diaSeleccionado,
                    items: dias.map((d){
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        diaSeleccionado = value;
                      });
                    },
                    validator: (value){
                      if(value == null){
                        return "Selecciona un día";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Selecciona la ruta",
                      border: OutlineInputBorder(),
                    ),
                    value: rutaSeleccionada,
                    items: rutas.map((r){
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        rutaSeleccionada = value;
                      });
                    },
                    validator: (value){
                      if(value == null){
                        return "Selecciona una ruta";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.03),

                  Container(
                    height: height * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: const MapaWidget(),
                  ),

                  SizedBox(height: height * 0.03),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Notificación minutos antes",
                      border: OutlineInputBorder(),
                    ),
                    value: minutosAntes,
                    items: tiempos.map((t){
                      return DropdownMenuItem(
                        value: t,
                        child: Text("$t minutos"),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        minutosAntes = value;
                      });
                    },
                    validator: (value){
                      if(value == null){
                        return "Selecciona el tiempo";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: "Título del recordatorio",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Este campo es obligatorio";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  TextFormField(
                    controller: descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción (opcional)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      SizedBox(
                        width: width * 0.40,
                        height: height * 0.06,
                        child: OutlinedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text("Cancelar"),
                        ),
                      ),

                      SizedBox(
                        width: width * 0.40,
                        height: height * 0.06,
                        child: ElevatedButton(
                          onPressed: () async {

                            if(_formKey.currentState!.validate()){
                              await controlador.actualizarRecordatorio(
                                idDoc: widget.idRecordatorioDoc,
                                titulo: tituloController.text,
                                descripcion: descripcionController.text,
                                minutosAntes: minutosAntes!,
                                dia: diaSeleccionado!,
                                ruta: rutaSeleccionada!,
                              );

                              Navigator.pop(context, true);
                            }
                          },
                          child: const Text("Guardar"),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.05),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}