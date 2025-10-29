import 'package:flutter/material.dart';
import 'dart:ui';



/// Класс для пользовательского виджета навигационного меню
class CustomBottomNavBar extends StatelessWidget {


  final int currentIndex;
  final Function(int) onTap;
  final List<NavButtonData> items;


  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });


  @override
  Widget build(BuildContext context) {

    return Align(

      alignment: Alignment.bottomCenter,

      child: Padding(

        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(28),

          child: BackdropFilter(

            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                  color: Color.fromARGB((0.01 * 255).round(), 0, 0, 0),
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

              child: Row(

                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,

                children: List.generate(items.length, (index) {

                  final item = items[index];

                  return Row(

                    children: [

                      GestureDetector(
                        onTap: () => onTap(index),
                        child: _buildNavButton(
                          icon: item.icon,
                          label: item.label,
                          selected: currentIndex == index,
                        ),
                      ),

                      if (index != items.length - 1) const SizedBox(width: 14),

                    ],
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


/// Одна кнопка NavBar
Widget _buildNavButton({

  required IconData icon,
  required String label,
  required bool selected,

}) {
  return AnimatedContainer(

    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    padding: EdgeInsets.symmetric(
      horizontal: selected ? 20 : 12,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: selected ? Colors.black87 : Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        if (selected)
          BoxShadow(
            color: Color.fromARGB((0.35 * 255).round(), 0, 0, 0),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
      ],
    ),

    child: Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(
          icon,
          color: selected ? Colors.white : Colors.black87,
        ),

        // Показываем текст только если кнопка выбрана
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: selected
              ? Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          )
              : const SizedBox.shrink(),
        ),

      ],
    ),
  );
}



class NavButtonData {

  final IconData icon;
  final String label;

  const NavButtonData({required this.icon, required this.label});
}


