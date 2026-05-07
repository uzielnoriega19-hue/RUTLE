import 'package:flutter/material.dart';

void mostrarExito(BuildContext context, String mensaje) =>
    _mostrarToast(context, mensaje, esError: false);

void mostrarError(BuildContext context, String mensaje) =>
    _mostrarToast(context, mensaje, esError: true);

void _mostrarToast(BuildContext context, String mensaje,
    {required bool esError}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _Toast(
      mensaje: mensaje,
      esError: esError,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  final String mensaje;
  final bool esError;
  final VoidCallback onDismiss;

  const _Toast({
    required this.mensaje,
    required this.esError,
    required this.onDismiss,
  });

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _slide = Tween<Offset>(begin: const Offset(0, -1.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 14;

    final coloresExito = [const Color(0xFF2E7D32), const Color(0xFF43A047)];
    final coloresError = [const Color(0xFFC62828), const Color(0xFFE53935)];
    final colores = widget.esError ? coloresError : coloresExito;
    final icono = widget.esError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Positioned(
      top: top,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colores,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colores.last.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icono, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.mensaje,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
