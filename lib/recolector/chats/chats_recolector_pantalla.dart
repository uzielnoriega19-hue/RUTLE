import 'package:flutter/material.dart';

class ChatsRecolectorPantalla extends StatelessWidget {
  const ChatsRecolectorPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

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
        title: const Text('Chats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 12),
            Text(
              'En construcción',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
