import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controladores/nuevos_foros_controlador.dart';
import 'package:rutle_test/modulos/foros/pantallas/filtros_foro_pantalla.dart';

class NuevosForosPantalla extends StatefulWidget {
  const NuevosForosPantalla({super.key});

  @override
  State<NuevosForosPantalla> createState() => _NuevosForosPantallaState();
}

class _NuevosForosPantallaState extends State<NuevosForosPantalla> {
  final TextEditingController buscarController = TextEditingController();
  final NuevosForosControlador controlador = NuevosForosControlador();

  Map<String, dynamic> filtrosAplicados = {};

  void volver(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/forosPrincipal');
    }
  }

  bool _cumpleFiltros(Map<String, dynamic> foro) {
    final texto = buscarController.text.trim().toLowerCase();

    final titulo = (foro['titulo'] ?? '').toString().toLowerCase();

    if (texto.isNotEmpty && !titulo.contains(texto)) {
      return false;
    }

    if (filtrosAplicados.isEmpty) return true;

    final privacidad = filtrosAplicados['privacidad'];

    if (privacidad != null && privacidad != 'todos') {
      if ((foro['privacidad'] ?? '') != privacidad) return false;
    }

    final miembros = (foro['miembros'] as List?)?.length ?? 0;

    final minRaw = filtrosAplicados['min'];
    final maxRaw = filtrosAplicados['max'];

    final int? min = (minRaw is int)
        ? minRaw
        : int.tryParse(minRaw?.toString() ?? '');

    final int? max = (maxRaw is int)
        ? maxRaw
        : int.tryParse(maxRaw?.toString() ?? '');

    if (min != null && miembros < min) return false;
    if (max != null && miembros > max) return false;

    final rutasFiltro = (filtrosAplicados['rutas'] as List?) ?? [];
    final rutasForo = foro['rutas'] ?? [];

    if (rutasFiltro.isNotEmpty) {
      final tieneRuta = rutasFiltro.any((r) {
        return rutasForo.any((f) => f['ruta'] == r);
      });

      if (!tieneRuta) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
                  : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Nuevos foros',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => volver(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controlador.obtenerForosOrdenados(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final foros = snapshot.data!
                        .where(_cumpleFiltros)
                        .toList();

                    if (foros.isEmpty) {
                      return const Center(child: Text('No hay foros'));
                    }

                    return ListView.builder(
                      itemCount: foros.length,
                      itemBuilder: (context, index) {
                        final foro = foros[index];
                        final cs = Theme.of(context).colorScheme;

                        final miembros =
                            (foro['miembros'] as List?)?.length ?? 0;
                        final fechaRaw = foro['fechaCreacion'];
                        final fecha = fechaRaw is Timestamp
                            ? fechaRaw.toDate()
                            : DateTime.now();

                        return Container(
                          margin: EdgeInsets.only(bottom: size.height * 0.015),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/detalleForo',
                                arguments: foro,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    // Borde izquierdo de acento azul
                                    Container(
                                      width: 4,
                                      color: cs.primary,
                                    ),
                                    Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(size.width * 0.04),
                                      child: Row(
                                        children: [
                                          // Ícono con fondo primaryContainer
                                          Container(
                                            width: size.width * 0.14,
                                            height: size.width * 0.14,
                                            decoration: BoxDecoration(
                                              color: cs.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.forum_rounded,
                                              size: size.width * 0.07,
                                              color: cs.onPrimaryContainer,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.04),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  foro['titulo'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: size.width * 0.042,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.onSurface,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.006),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.group_outlined,
                                                      size: size.width * 0.035,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    Text(
                                                      '$miembros miembros',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.width * 0.033,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.004),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today_outlined,
                                                      size: size.width * 0.033,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    Text(
                                                      '${fecha.day}/${fecha.month}/${fecha.year}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.width * 0.033,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ),  // cierra Expanded
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Separador visual entre lista y buscador
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      child: Text(
                        'Buscar',
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: buscarController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar foros...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FiltrosForoPantalla(),
                            ),
                          );
                          if (result != null) {
                            setState(() => filtrosAplicados = result);
                          }
                        },
                        icon: Icon(
                          Icons.tune,
                          size: size.width * 0.045,
                        ),
                        label: Text(
                          filtrosAplicados.isEmpty ? 'Filtros' : 'Filtros activos',
                          style: TextStyle(fontSize: size.width * 0.038),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                          ),
                          foregroundColor: filtrosAplicados.isEmpty
                              ? null
                              : Theme.of(context).colorScheme.tertiary,
                          side: BorderSide(
                            color: filtrosAplicados.isEmpty
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}