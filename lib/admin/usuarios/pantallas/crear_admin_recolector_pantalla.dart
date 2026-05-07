import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rutle_test/compartido/toast.dart';
import '../controladores/crear_admin_recolector_controlador.dart';

class CrearAdminRecolectorPantalla extends StatefulWidget {
  const CrearAdminRecolectorPantalla({super.key});

  @override
  State<CrearAdminRecolectorPantalla> createState() =>
      _CrearAdminRecolectorPantallaState();
}

class _HorarioDia {
  final TimeOfDay inicio;
  final TimeOfDay fin;
  const _HorarioDia({required this.inicio, required this.fin});
  _HorarioDia copyWith({TimeOfDay? inicio, TimeOfDay? fin}) =>
      _HorarioDia(inicio: inicio ?? this.inicio, fin: fin ?? this.fin);
}

class _CrearAdminRecolectorPantallaState
    extends State<CrearAdminRecolectorPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = CrearAdminRecolectorControlador();

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  String _rol = 'admin';

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final __dialogPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dialogPassCtrl = TextEditingController();
  bool _verPass = false;
  bool _verConfirm = false;

  // Horario por día (solo recolector)
  final Map<String, _HorarioDia> _horarioDias = {};

  bool _guardando = false;

  static const _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    __dialogPassCtrl.dispose();
    _confirmCtrl.dispose();
    _dialogPassCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Limpiar al cambiar rol ──────────────────────────────────────

  void _cambiarRol(String nuevoRol) {
    if (nuevoRol == _rol) return;
    _nombreCtrl.clear();
    _correoCtrl.clear();
    __dialogPassCtrl.clear();
    _confirmCtrl.clear();
    _horarioDias.clear();
    setState(() {
      _rol = nuevoRol;
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  // ─── Toggle día ──────────────────────────────────────────────────

  void _toggleDia(String dia) {
    setState(() {
      if (_horarioDias.containsKey(dia)) {
        _horarioDias.remove(dia);
      } else {
        _horarioDias[dia] = const _HorarioDia(
          inicio: TimeOfDay(hour: 7, minute: 0),
          fin: TimeOfDay(hour: 15, minute: 0),
        );
      }
    });
  }

  // ─── Pick time por día ───────────────────────────────────────────

  Future<void> _pickTime(String dia, bool esInicio) async {
    final h = _horarioDias[dia]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: esInicio ? h.inicio : h.fin,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _horarioDias[dia] = esInicio
          ? h.copyWith(inicio: picked)
          : h.copyWith(fin: picked);
    });
  }

  // ─── Diálogo confirmación contraseña admin ───────────────────────

  Future<bool> _mostrarDialogoPassword() async {
    _dialogPassCtrl.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool verPass = false;
        String? errorText;
        bool cargando = false;

        return StatefulBuilder(builder: (ctx, setS) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      LinearGradient(colors: gradColors).createShader(b),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 8),
                const Text('Confirmar identidad',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Introduce tu contraseña de admin para confirmar la creación.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dialogPassCtrl,
                  obscureText: !verPass,
                  autofocus: true,
                  onChanged: (_) {
                    if (errorText != null) setS(() => errorText = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Tu contraseña',
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                    suffixIcon: IconButton(
                      icon: Icon(verPass
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setS(() => verPass = !verPass),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: cargando
                    ? null
                    : () => Navigator.of(ctx, rootNavigator: true)
                        .pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: cargando
                    ? null
                    : () async {
                        setS(() {
                          cargando = true;
                          errorText = null;
                        });
                        final ok = await _verificarPasswordAdmin(
                            _dialogPassCtrl.text.trim());
                        if (!ctx.mounted) return;
                        if (ok) {
                          Navigator.of(ctx, rootNavigator: true).pop(true);
                        } else {
                          setS(() {
                            cargando = false;
                            errorText = 'Contraseña incorrecta';
                          });
                        }
                      },
                child: cargando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Confirmar'),
              ),
            ],
          ),  // AlertDialog
          );  // PopScope
        });
      },
    );

    return confirmado == true;
  }

  Future<bool> _verificarPasswordAdmin(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Crear usuario ───────────────────────────────────────────────

  Future<void> _crear() async {
    final formValido = _formKey.currentState!.validate();
    if (!formValido) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    if (__dialogPassCtrl.text != _confirmCtrl.text) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      mostrarError(context, 'Las contraseñas no coinciden');
      return;
    }
    if (_rol == 'recolector' && _horarioDias.isEmpty) {
      mostrarError(context, 'Selecciona al menos un día de trabajo');
      return;
    }

    // Pedir confirmación con contraseña de admin
    final confirmado = await _mostrarDialogoPassword();
    if (confirmado != true || !mounted) return;

    setState(() => _guardando = true);

    Map<String, Map<String, String>>? horario;
    if (_rol == 'recolector' && _horarioDias.isNotEmpty) {
      horario = {
        for (final e in _horarioDias.entries)
          e.key: {'inicio': _fmt(e.value.inicio), 'fin': _fmt(e.value.fin)}
      };
    }

    final resultado = await _ctrl.crearUsuario(
      nombreUsuario: _nombreCtrl.text,
      correo: _correoCtrl.text,
      password: __dialogPassCtrl.text,
      rol: _rol,
      horario: horario,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (resultado == 'OK') {
      final label = _rol == 'admin' ? 'Admin' : 'Recolector';
      final nombre = _nombreCtrl.text.trim();
      mostrarExito(context, '¡$label "$nombre" creado correctamente!');
      Navigator.pop(context);
    } else {
      mostrarError(context, resultado);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final gradColors = isDark
        ? const [Color(0xFF1C3F71), Color(0xFF1B78C9)]
        : const [Color(0xFF00ACC1), Color(0xFF6FD3FF)];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nuevo usuario',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.025,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Selector de rol ──────────────────────────────
                Text(
                  'Rol',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.04,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                Row(
                  children: [
                    Expanded(
                      child: _RolCard(
                        label: 'Admin',
                        icono: Icons.admin_panel_settings_rounded,
                        seleccionado: _rol == 'admin',
                        gradColors: gradColors,
                        cs: cs,
                        onTap: () => _cambiarRol('admin'),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: _RolCard(
                        label: 'Recolector',
                        icono: Icons.directions_bus_rounded,
                        seleccionado: _rol == 'recolector',
                        gradColors: gradColors,
                        cs: cs,
                        onTap: () => _cambiarRol('recolector'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.03),
                Divider(color: cs.outline.withValues(alpha: 0.25)),
                SizedBox(height: size.height * 0.02),

                // ── Nombre ────────────────────────────────────────
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),

                SizedBox(height: size.height * 0.02),

                // ── Gmail ─────────────────────────────────────────
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Gmail',
                    prefixIcon: Icon(Icons.email_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                    if ('@'.allMatches(v).length != 1) {
                      return 'El correo debe tener exactamente un @';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(v.trim())) return 'Formato de correo inválido';
                    return null;
                  },
                ),

                SizedBox(height: size.height * 0.02),

                // ── Contraseña ────────────────────────────────────
                TextFormField(
                  controller: __dialogPassCtrl,
                  obscureText: !_verPass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _verPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verPass = !_verPass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obligatorio';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                SizedBox(height: size.height * 0.02),

                // ── Confirmar contraseña ──────────────────────────
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_verConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_verConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _verConfirm = !_verConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obligatorio';
                    if (v != __dialogPassCtrl.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),

                // ── Horario (solo recolector) ─────────────────────
                if (_rol == 'recolector') ...[
                  SizedBox(height: size.height * 0.03),
                  Divider(color: cs.outline.withValues(alpha: 0.25)),
                  SizedBox(height: size.height * 0.02),

                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 20, color: gradColors.last),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Horario laboral',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.04,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.015),

                  // Chips de días
                  Text(
                    'Días de trabajo',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Wrap(
                    spacing: size.width * 0.02,
                    runSpacing: size.height * 0.008,
                    children: _diasSemana.map((dia) {
                      final sel = _horarioDias.containsKey(dia);
                      return GestureDetector(
                        onTap: () => _toggleDia(dia),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.032,
                            vertical: size.height * 0.009,
                          ),
                          decoration: BoxDecoration(
                            gradient: sel
                                ? LinearGradient(
                                    colors: gradColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: sel ? null : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? Colors.transparent
                                  : cs.outline.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            dia.length > 3 ? dia.substring(0, 3) : dia,
                            style: TextStyle(
                              fontSize: size.width * 0.033,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : cs.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Horario por día
                  if (_horarioDias.isNotEmpty) ...[
                    SizedBox(height: size.height * 0.022),
                    Text(
                      'Horario por día',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    ..._diasSemana
                        .where((d) => _horarioDias.containsKey(d))
                        .map((dia) => _FilaHorarioDia(
                              dia: dia,
                              horario: _horarioDias[dia]!,
                              gradColors: gradColors,
                              cs: cs,
                              size: size,
                              onPickInicio: () => _pickTime(dia, true),
                              onPickFin: () => _pickTime(dia, false),
                              fmt: _fmt,
                            )),
                  ],
                ],

                SizedBox(height: size.height * 0.04),

                // ── Botones ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.018),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradColors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.018),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            onPressed: _guardando ? null : _crear,
                            child: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Crear',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fila de horario por día ──────────────────────────────────────────────────

class _FilaHorarioDia extends StatelessWidget {
  final String dia;
  final _HorarioDia horario;
  final List<Color> gradColors;
  final ColorScheme cs;
  final Size size;
  final VoidCallback onPickInicio;
  final VoidCallback onPickFin;
  final String Function(TimeOfDay) fmt;

  const _FilaHorarioDia({
    required this.dia,
    required this.horario,
    required this.gradColors,
    required this.cs,
    required this.size,
    required this.onPickInicio,
    required this.onPickFin,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.012),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // Nombre del día
          SizedBox(
            width: size.width * 0.22,
            child: Text(
              dia,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.034,
                color: cs.onSurface,
              ),
            ),
          ),

          // Entrada
          Expanded(
            child: GestureDetector(
              onTap: onPickInicio,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.008,
                  horizontal: size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Entrada',
                      style: TextStyle(
                        fontSize: size.width * 0.026,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    isDark
                        ? Text(
                            fmt(horario.inicio),
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                                    colors: gradColors)
                                .createShader(b),
                            child: Text(
                              fmt(horario.inicio),
                              style: TextStyle(
                                fontSize: size.width * 0.042,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            child: Icon(Icons.arrow_forward_rounded,
                size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
          ),

          // Salida
          Expanded(
            child: GestureDetector(
              onTap: onPickFin,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.008,
                  horizontal: size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Salida',
                      style: TextStyle(
                        fontSize: size.width * 0.026,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    isDark
                        ? Text(
                            fmt(horario.fin),
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                                    colors: gradColors)
                                .createShader(b),
                            child: Text(
                              fmt(horario.fin),
                              style: TextStyle(
                                fontSize: size.width * 0.042,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de rol ───────────────────────────────────────────────────────────

class _RolCard extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool seleccionado;
  final List<Color> gradColors;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _RolCard({
    required this.label,
    required this.icono,
    required this.seleccionado,
    required this.gradColors,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: size.height * 0.022),
        decoration: BoxDecoration(
          gradient: seleccionado
              ? LinearGradient(
                  colors: gradColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: seleccionado ? null : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? Colors.transparent
                : cs.outline.withValues(alpha: 0.3),
            width: seleccionado ? 0 : 1.5,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: gradColors.last.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono,
                size: 30,
                color: seleccionado
                    ? Colors.white
                    : cs.onSurface.withValues(alpha: 0.6)),
            SizedBox(height: size.height * 0.008),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.038,
                color: seleccionado
                    ? Colors.white
                    : cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
