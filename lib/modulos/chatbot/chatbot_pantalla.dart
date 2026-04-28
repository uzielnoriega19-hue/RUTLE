import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chatbot_controlador.dart';

class ChatbotPantalla extends StatelessWidget {
  const ChatbotPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatbotControlador(),
      child: const _ChatbotVista(),
    );
  }
}

class _ChatbotVista extends StatelessWidget {
  const _ChatbotVista();

  @override
  Widget build(BuildContext context) {
    final controlador = Provider.of<ChatbotControlador>(context);
    final nodo = controlador.obtenerNodoActual();
    final height = MediaQuery.of(context).size.height;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Column(
          children: [
            Container(
              height: height * 0.50,
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                controller: controlador.scrollController,
                itemCount: controlador.mensajes.length,
                itemBuilder: (context, index) {
                  final mensaje = controlador.mensajes[index];
                  return Align(
                    alignment: mensaje.esBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            mensaje.esBot ? Colors.grey.shade300 : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mensaje.texto,
                        style: TextStyle(
                          color: mensaje.esBot ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!controlador.chatCompleto && !controlador.preguntaAbierta)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: nodo.opciones.map((opcion) {
                        return ElevatedButton(
                          onPressed: () =>
                              controlador.seleccionarOpcion(opcion),
                          child: Text(opcion.texto),
                        );
                      }).toList(),
                    ),
                  if (controlador.preguntaAbierta && !controlador.chatCompleto)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controlador.inputController,
                            decoration: const InputDecoration(
                              hintText: "Escribe tu respuesta...",
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                controlador.guardarRespuestaAbierta(value);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            final texto = controlador.inputController.text.trim();
                            if (texto.isNotEmpty) {
                              controlador.guardarRespuestaAbierta(texto);
                            }
                          },
                        )
                      ],
                    ),
                  const SizedBox(height: 15),
                  if (controlador.chatCompleto)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: controlador.enviarAFirebase,
                          child: const Text("Enviar reporte"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: controlador.cancelarReporte,
                          child: const Text("Cancelar reporte"),
                        ),
                      ],
                    ),
                  if (!controlador.chatCompleto && controlador.pasos.isNotEmpty)
                    ElevatedButton(
                      onPressed: () => controlador.retroceder(),
                      child: const Text("Regresar"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}