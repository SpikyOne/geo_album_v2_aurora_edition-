import 'package:flutter/material.dart';
import 'dart:ui';



/// Класс виджета для организации бокового меню
class CustomActionMenu extends StatelessWidget {

  // Ориентация меню. Может быть справа сбоку, снизу по центру
  final Axis orientation;

  // Набор элементов меню --- кнопок
  final List<MenuItem> items;

  // Настраиваемый интервал между кнопками
  final double spacing;

  // Настраиваемый размер кнопок
  final double buttonSize;

  // Callback нажатия
  final Function(int)? onTap;



  const CustomActionMenu({
    super.key,
    required this.items,
    this.orientation = Axis.horizontal,
    this.spacing = 8.0,
    this.buttonSize = 56.0,
    this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    final isHorizontal = orientation == Axis.horizontal;

    return Align(

      alignment: isHorizontal ? Alignment.bottomCenter : Alignment.centerRight,

      child: Padding(

        padding: EdgeInsets.only(
          bottom: isHorizontal ? MediaQuery.of(context).padding.bottom + 32 : 0,
          right: isHorizontal ? 0 : 4,
        ),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(28),

          child: BackdropFilter(

            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(

              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Color.fromARGB((0.03 * 255).round(), 0, 0, 0),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Color.fromARGB((0.35 * 255).round(), 255, 255, 255),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((0.05 * 255).round(), 0, 0, 0),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Flex(

                direction: orientation,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,

                children: List.generate(items.length, (index) {

                  final item = items[index];

                  return Padding(

                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? spacing / 2 : 0,
                      vertical: isHorizontal ? 0 : spacing / 2,
                    ),

                    child: GestureDetector(
                      onTap: item.onTap,
                      child: _buildButton(
                        icon: item.icon,
                        label: item.label,
                        isHorizontal: isHorizontal,
                        size: buttonSize,
                      ),
                    ),

                  );
                }),


              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Класс для описания пункта меню --- кнопки
class MenuItem {

  // Иконка кнопки
  final IconData icon;

  // Необязательная подпись кнопки
  final String? label;


  final VoidCallback? onTap;


  const MenuItem(this.icon, {this.label, this.onTap});
}


/// Виджет отдельной кнопки меню
Widget _buildButton({
  required IconData icon,
  required bool isHorizontal,
  required double size,
  String? label,
}) {
  return AnimatedContainer(

    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Color.fromARGB((0.35 * 255).round(), 0, 0, 0),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: isHorizontal
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: size * 0.4),
        if (label != null && label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
      ],
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: size * 0.4),
        if (label != null && label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    ),
  );
}
