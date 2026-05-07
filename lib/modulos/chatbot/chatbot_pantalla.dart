import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rutle_test/compartido/toast.dart';
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

  Widget _boton(BuildContext context, String texto, VoidCallback? onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Text(texto),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = Provider.of<ChatbotControlador>(context);
    final nodo = controlador.obtenerNodoActual();
    final height = MediaQuery.of(context).size.height;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                  : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Chatbot',
          style: TextStyle(color: Colors.white),
        ),
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
                        color: mensaje.esBot
                            ? Colors.grey.shade300
                            : Colors.blue,
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
                        return _boton(
                          context,
                          opcion.texto,
                          () => controlador.seleccionarOpcion(opcion),
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
                            final texto =
                                controlador.inputController.text.trim();
                            if (texto.isNotEmpty) {
                              controlador.guardarRespuestaAbierta(texto);
                            }
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 15),
                  if (controlador.chatCompleto)
                    Row(
                      children: [
                        Expanded(
                          child: _boton(
                            context,
                            "Enviar reporte",
                            () async {
                              try {
                                await controlador.enviarAFirebase();
                                if (context.mounted) {
                                  mostrarExito(
                                    context,
                                    '¡Reporte enviado correctamente!',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  mostrarError(
                                    context,
                                    'Error al enviar el reporte',
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _boton(context, "Cancelar",
                              controlador.cancelarReporte),
                        ),
                      ],
                    ),
                  if (!controlador.chatCompleto &&
                      controlador.pasos.isNotEmpty)
                    _boton(
                        context, "Regresar", () => controlador.retroceder()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
