import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/principal/widgets/mapa_widget.dart';
import '../controladores/agregar_recordatorio_controlador.dart';

class AgregarRecordatorioPantalla extends StatefulWidget {
  const AgregarRecordatorioPantalla({super.key});

  @override
  State<AgregarRecordatorioPantalla> createState() =>
      _AgregarRecordatorioPantallaState();
}

class _AgregarRecordatorioPantallaState
    extends State<AgregarRecordatorioPantalla> {
  final controlador = AgregarRecordatorioControlador();
  final _formKey = GlobalKey<FormState>();

  String? diaSeleccionado;
  String? rutaSeleccionada;
  int? minutosAntes;

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

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
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Recordatorio"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.03),
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

                  SizedBox(height: size.height * 0.02),

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

                  SizedBox(height: size.height * 0.03),

                  Container(
                    height: size.height * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: const MapaWidget(
                      zoom: 15.5,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

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

                  SizedBox(height: size.height * 0.02),

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

                  SizedBox(height: size.height * 0.02),

                  TextFormField(
                    controller: descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción (opcional)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      SizedBox(
                        width: size.width * 0.40,
                        height: size.height * 0.06,
                        child: OutlinedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text("Cancelar"),
                        ),
                      ),

                      SizedBox(
                        width: size.width * 0.40,
                        height: size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: () async {

                            if(_formKey.currentState!.validate()){
                              await controlador.guardarRecordatorio(
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

                  SizedBox(height: size.height * 0.05),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}