import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Локальные импорты
import '../widgets/section_header.dart';
import '../widgets/photo_tile.dart';
import '../screens/photo_view_screen.dart';
import '../providers/navigation_provider.dart';
import '../providers/image_provider.dart';
import '../models/image_data_model.dart';



/// Экран Галереи
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}


class _GalleryScreenState extends State<GalleryScreen> {

  double _lastScale = 1.0;
  double _scaleAccumulator = 0.0; // аккумулирует разницу

  // порог  (0.35 = нормально)
  static const double _scaleThreshold = 0.35;

  // Текущее количество колонок
  int _columns = 3;

  // Минимум колонок
  static const int _minColumns = 1;

  // Максимум колонок
  static const int _maxColumns = 8;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    // Расчёт ширины одной плитки:
    // из ширины экрана вычитаем суммарный отступ между колонками
    // и делим на количество колонок
    final spacingRatio = 0.08; // 8 %
    final totalSpacing = (_columns - 1);
    final tileWidth = screenWidth / (_columns + totalSpacing * spacingRatio);
    final axisSpacing = tileWidth * spacingRatio;

    return Scaffold(

      body: GestureDetector(

        onScaleStart: (details) {
          _lastScale = 1.0;
          _scaleAccumulator = 0.0;
        },
        onScaleUpdate: (details) {

          // маленькие приращения (обычно ~0.01..0.2)
          final delta = details.scale - _lastScale;
          _scaleAccumulator += delta;

          // срабатываем только когда накоплено достаточно (чтобы снизить чувствительность)
          if (_scaleAccumulator.abs() >= _scaleThreshold) {

            setState(() {

              // жест "растягивание" -> сделать плитки крупнее => МЕНЬШЕ колонок
              if (_scaleAccumulator > 0) { _columns = (_columns - 1).clamp(_minColumns, _maxColumns); }

              // жест "сжимание" -> плитки мельче => БОЛЬШЕ колонок
              else { _columns = (_columns + 1).clamp(_minColumns, _maxColumns); }

            });

            // Сброс аккумулятора, но не полностью — оставим "остаток" для плавности
            _scaleAccumulator = 0.0;
          }

          // обновляем _lastScale (не details.scale напрямую, чтобы delta было корректным)
          _lastScale = details.scale;
        },


        child: Stack(
          children: [

            // Определение содержимого экрана
            Consumer<GalleryProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.loadError) {
                  return _buildError();
                } else if (provider.images.isEmpty) {
                  return _buildEmpty();
                } else {
                  return _buildGrid(provider.images, axisSpacing);
                }
              },
            ),

            const SectionHeader(title: 'Галерея фотографий'),
          ],
        ),
      ),
      );
  }


  /// Виджет неудачной загрузки фотографий в галерею
  Widget _buildError() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: Colors.red),
        SizedBox(height: 16),
        Text(
          'Не удалось загрузить фото',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );


  /// Виджет пустой галереи
  Widget _buildEmpty() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Галерея пока пуста :(',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );


  /// Виджет галереи с изображениями
  Widget _buildGrid(List<GalleryImage> images, double axisSpacing) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),

      child: SingleChildScrollView(
        child: Column(
          children: [
            // Пустое пространство сверху
            const SizedBox(height: 100),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),

              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,

              // fade + scale для более мягкого эффекта
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                );
              },

              child: GridView.builder(

                key: ValueKey<int>(_columns),
                shrinkWrap: true, // grid подстраивается под содержимое
                physics: const NeverScrollableScrollPhysics(), // Scroll только у SingleChildScrollView

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  crossAxisSpacing: axisSpacing,
                  mainAxisSpacing: axisSpacing,
                ),

                itemCount: images.length,
                itemBuilder: (context, index) {

                  final img = images[index];

                  return PhotoTile(

                    image: img,

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotoViewScreen(
                            image: img,
                            previousIndex: context.read<NavigationProvider>().currentIndex,
                          ),
                        ),
                      );
                    }
                    ,
                  );

                },
              ),
            ),

            // Пустое пространство снизу
            const SizedBox(height: 180),

          ],

        ),
      ),
    );
  }

}
