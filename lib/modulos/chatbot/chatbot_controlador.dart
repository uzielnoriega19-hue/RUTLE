import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MensajeChat {
  final String texto;
  final bool esBot;

  MensajeChat({required this.texto, required this.esBot});
}

class OpcionChat {
  final String texto;
  final String siguiente;
  final bool preguntaAbierta;

  OpcionChat({
    required this.texto,
    required this.siguiente,
    this.preguntaAbierta = false,
  });
}

class NodoChat {
  final String id;
  final String mensaje;
  final List<OpcionChat> opciones;

  NodoChat({
    required this.id,
    required this.mensaje,
    required this.opciones,
  });
}

class HistorialPaso {
  final String nodo;
  final String respuesta;

  HistorialPaso(this.nodo, this.respuesta);

  Map<String, dynamic> toMap() {
    return {
      'nodo': nodo,
      'respuesta': respuesta,
    };
  }
}

class ChatbotControlador extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  List<MensajeChat> mensajes = [];
  List<HistorialPaso> pasos = [];

  bool preguntaAbierta = false;
  bool chatCompleto = false;

  String nodoActual = "inicio";

  bool get esInicio => nodoActual == "inicio";
  
  final Map<String, NodoChat> nodos = {
    "inicio": NodoChat(
      id: "inicio",
      mensaje: "¿Sobre qué quieres reportar un problema?",
      opciones: [
        OpcionChat(texto: "Rutas", siguiente: "rutas"),
        OpcionChat(texto: "Recolectores", siguiente: "recolectores"),
        OpcionChat(texto: "App", siguiente: "app"),
        OpcionChat(texto: "Foros", siguiente: "foros"),
      ],
    ),
    "rutas": NodoChat(
      id: "rutas",
      mensaje: "¿Qué problema ocurrió con la ruta?",
      opciones: [
        OpcionChat(texto: "El camión no pasó", siguiente: "ruta_detalle"),
        OpcionChat(texto: "Pasó tarde", siguiente: "ruta_detalle"),
        OpcionChat(texto: "Otro problema", siguiente: "ruta_detalle"),
      ],
    ),
    "ruta_detalle": NodoChat(
      id: "ruta_detalle",
      mensaje: "Describe el problema.",
      opciones: [
        OpcionChat(
          texto: "Escribir comentario",
          siguiente: "ruta_texto",
          preguntaAbierta: true,
        ),
      ],
    ),
    "ruta_texto": NodoChat(
      id: "ruta_texto",
      mensaje: "Escribe el detalle.",
      opciones: [],
    ),
    "recolectores": NodoChat(
      id: "recolectores",
      mensaje: "¿Qué ocurrió con el recolector?",
      opciones: [
        OpcionChat(texto: "Mal trato", siguiente: "recolector_detalle"),
        OpcionChat(texto: "No recogió basura", siguiente: "recolector_detalle"),
        OpcionChat(texto: "Otro problema", siguiente: "recolector_detalle"),
      ],
    ),
    "recolector_detalle": NodoChat(
      id: "recolector_detalle",
      mensaje: "Describe lo ocurrido.",
      opciones: [
        OpcionChat(
          texto: "Escribir descripción",
          siguiente: "recolector_texto",
          preguntaAbierta: true,
        ),
      ],
    ),
    "recolector_texto": NodoChat(
      id: "recolector_texto",
      mensaje: "Escribe el detalle.",
      opciones: [],
    ),
    "app": NodoChat(
      id: "app",
      mensaje: "¿Qué problema tienes con la aplicación?",
      opciones: [
        OpcionChat(texto: "No carga", siguiente: "app_detalle"),
        OpcionChat(texto: "Error en funciones", siguiente: "app_detalle"),
        OpcionChat(texto: "Otro error", siguiente: "app_detalle"),
      ],
    ),
    "app_detalle": NodoChat(
      id: "app_detalle",
      mensaje: "Describe el error.",
      opciones: [
        OpcionChat(
          texto: "Escribir error",
          siguiente: "app_texto",
          preguntaAbierta: true,
        ),
      ],
    ),
    "app_texto": NodoChat(
      id: "app_texto",
      mensaje: "Escribe el problema.",
      opciones: [],
    ),
    "foros": NodoChat(
      id: "foros",
      mensaje: "¿Qué problema hay en el foro?",
      opciones: [
        OpcionChat(texto: "Contenido inapropiado", siguiente: "foro_detalle"),
        OpcionChat(texto: "Spam", siguiente: "foro_detalle"),
        OpcionChat(texto: "Otro problema", siguiente: "foro_detalle"),
      ],
    ),
    "foro_detalle": NodoChat(
      id: "foro_detalle",
      mensaje: "Describe el problema.",
      opciones: [
        OpcionChat(
          texto: "Escribir reporte",
          siguiente: "foro_texto",
          preguntaAbierta: true,
        ),
      ],
    ),
    "foro_texto": NodoChat(
      id: "foro_texto",
      mensaje: "Escribe el detalle.",
      opciones: [],
    ),
    "fin": NodoChat(
      id: "fin",
      mensaje: "Tu reporte está listo para enviarse.",
      opciones: [],
    ),
  };

  ChatbotControlador() {
    iniciar();
  }

  void agregarBot(String texto) {
    if (mensajes.isEmpty) {
      mensajes.add(MensajeChat(texto: texto, esBot: true));
      return;
    }
    final ultimo = mensajes.last;
    if (ultimo.esBot && ultimo.texto == texto) return;
    mensajes.add(MensajeChat(texto: texto, esBot: true));
  }

  void iniciar() {
    pasos.clear();
    nodoActual = "inicio";
    mensajes.clear();
    agregarBot(nodos[nodoActual]!.mensaje);
  }

  NodoChat obtenerNodoActual() {
    return nodos[nodoActual]!;
  }

  void seleccionarOpcion(OpcionChat opcion) {
    pasos.add(HistorialPaso(nodoActual, opcion.texto));
    reconstruirChat();
    nodoActual = opcion.siguiente;
    final nodo = nodos[nodoActual]!;
    preguntaAbierta = opcion.preguntaAbierta;
    agregarBot(nodo.mensaje);
    if (nodo.opciones.isEmpty && !preguntaAbierta) {
      nodoActual = "fin";
      chatCompleto = true;
      agregarBot(nodos["fin"]!.mensaje);
    }
    notifyListeners();
    scrollFinal();
  }

  void guardarRespuestaAbierta(String texto) {
    if (texto.trim().isEmpty) return;
    pasos.add(HistorialPaso(nodoActual, texto));
    reconstruirChat();
    nodoActual = "fin";
    agregarBot(nodos[nodoActual]!.mensaje);
    chatCompleto = true;
    inputController.clear();
    notifyListeners();
    scrollFinal();
  }

  void cancelarReporte() {
    pasos.clear();
    nodoActual = "inicio";
    chatCompleto = false;
    preguntaAbierta = false;
    inputController.clear();
    mensajes.clear();
    agregarBot(nodos["inicio"]!.mensaje);
    notifyListeners();
    scrollFinal();
  }

  void retroceder() {
    if (pasos.isEmpty) return;
    pasos.removeLast();
    reconstruirChat();
    nodoActual = "inicio";
    for (final paso in pasos) {
      final opciones = nodos[paso.nodo]!.opciones;
      final opcion = opciones.where((o) => o.texto == paso.respuesta);
      if (opcion.isNotEmpty) {
        nodoActual = opcion.first.siguiente;
      }
    }
    preguntaAbierta = false;
    chatCompleto = false;
    agregarBot(nodos[nodoActual]!.mensaje);
    notifyListeners();
    scrollFinal();
  }

  void reconstruirChat() {
    mensajes.clear();
    agregarBot(nodos["inicio"]!.mensaje);
    String nodo = "inicio";
    for (final paso in pasos) {
      mensajes.add(MensajeChat(texto: paso.respuesta, esBot: false));
      final opciones = nodos[nodo]!.opciones;
      final opcion = opciones.where((o) => o.texto == paso.respuesta);
      if (opcion.isNotEmpty) {
        nodo = opcion.first.siguiente;
        agregarBot(nodos[nodo]!.mensaje);
      } else {
        nodo = "fin";
      }
    }
  }

  Future<void> enviarAFirebase() async {
    final data = pasos.map((p) => p.toMap()).toList();
    await FirebaseFirestore.instance.collection('chatbot').add({
      'fecha': DateTime.now(),
      'historial': data,
    });
    cancelarReporte();
  }

  void scrollFinal() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}