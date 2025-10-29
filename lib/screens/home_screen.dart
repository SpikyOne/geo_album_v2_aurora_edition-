import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../screens/gallery_screen.dart';
import '../screens/map_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/navigation_provider.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Навигатор
    final nav = context.watch<NavigationProvider>();
    final currentIndex = nav.currentIndex;

    // Переключаемые экраны
    final screens = [
      const GalleryScreen(),
      const MapScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [

          // Анимация для плавного переключения между экранами
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,

            child: KeyedSubtree(
              key: ValueKey<int>(currentIndex),
              child: screens[currentIndex],
            ),
          ),

          // Нижняя панель навигации и переключения между экраном галереи и карты
          CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => nav.setIndex(index),
            items: const [
              NavButtonData(icon: Icons.photo_library_rounded, label: 'Галерея'),
              NavButtonData(icon: Icons.map_rounded, label: 'Карта'),
            ],
          ),

        ],
      ),
    );
  }
}