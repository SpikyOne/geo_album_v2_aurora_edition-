import 'package:flutter/material.dart';
import 'dart:ui';


/// Универсальный виджет для верхнего заголовка раздела
class SectionHeader extends StatelessWidget {

  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16, // чуть ниже строки состояния
      left: 16,
      right: 16,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                //color: Colors.black.withOpacity(0.01), // было color: Colors.white.withOpacity(0.35),

                // Добавляем градиент
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB((0.1 * 255).round(), 128, 128, 128),
                    Color.fromARGB((0.3 * 255).round(), 128, 128, 128),
                    Color.fromARGB((0.1 * 255).round(), 128, 128, 128),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((0.05 * 255).round(), 0, 0, 0),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Color.fromARGB((0.35 * 255).round(), 255, 255, 255),
                  width: 1,
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}