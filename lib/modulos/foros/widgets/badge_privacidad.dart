import 'package:flutter/material.dart';

class BadgePrivacidad extends StatelessWidget {
  final String privacidad;
  const BadgePrivacidad({super.key, required this.privacidad});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esPrivado = privacidad.toLowerCase() == 'privado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: esPrivado ? cs.secondaryContainer : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: esPrivado ? cs.secondary : cs.tertiary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esPrivado ? Icons.lock_outline : Icons.public,
            size: 14,
            color: esPrivado ? cs.onSecondaryContainer : cs.onTertiaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            esPrivado ? 'Privado' : 'Público',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: esPrivado
                  ? cs.onSecondaryContainer
                  : cs.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
