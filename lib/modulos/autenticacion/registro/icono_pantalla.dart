import 'package:flutter/material.dart';
import 'registro_ui_controlador.dart';

class IconoPantalla extends StatefulWidget {
  final int avatarInicial;

  const IconoPantalla({super.key, required this.avatarInicial});

  @override
  State<IconoPantalla> createState() => _IconoPantallaState();
}

class _IconoPantallaState extends State<IconoPantalla> {
  late int seleccionado;

  @override
  void initState() {
    super.initState();
    seleccionado = widget.avatarInicial;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona tu icono")),

      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: avataresPermitidos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final id = avataresPermitidos[index];
          final isSelected = seleccionado == id;

          return GestureDetector(
            onTap: () {
              setState(() {
                seleccionado = id;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 161, 161, 161),
                borderRadius: BorderRadius.circular(15),
                border: isSelected
                    ? Border.all(color: Colors.greenAccent, width: 3)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          "https://api.dicebear.com/7.x/avataaars/png?seed=$id",
                        ),
                      ),
                    ],
                  ),

                  if (isSelected)
                    Positioned(
                      bottom: height * 0.02, // 🔽 más abajo y responsivo
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 26,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, seleccionado);
          },
          child: const Text("Confirmar"),
        ),
      ),
    );
  }
}