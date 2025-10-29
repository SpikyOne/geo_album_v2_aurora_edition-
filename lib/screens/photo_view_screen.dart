import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';

// Локальные импорты
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/image_data_model.dart';



// Класс виджета просмотра фотографии
class PhotoViewScreen extends StatefulWidget {


  final GalleryImage image;

  final int previousIndex; // 0 — галерея, 1 — карта

  const PhotoViewScreen({
    super.key,
    required this.image,
    required this.previousIndex,
  });

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  bool _uiVisible = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [

          // Отображение самого изображения с возможностью масштабирования
          GestureDetector(
            onTapUp: (_) => setState(() => _uiVisible = !_uiVisible),
            child: Center(
              child: InteractiveViewer(

                minScale: 1.0,
                maxScale: 50.0,
                clipBehavior: Clip.none,
                constrained: true, // учитывает размеры child
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: EdgeInsets.zero, // не даём выйти за границы

                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.file(widget.image.file, fit: BoxFit.contain),
                ),
              ),
            ),
          ),


          // Навигационное меню по возврату и переходу на карту
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _uiVisible ? 0 : -80, // скрываем вниз
            left: 0,
            right: 0,

            child: IgnorePointer(
              ignoring: !_uiVisible, // блокируем клики, если скрыто

              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _uiVisible ? 1 : 0,

                child: CustomBottomNavBar(

                  currentIndex: 1, // фиктивный индекс "просмотра"
                  onTap: (index) {

                    // Кнопка "Назад" возвращает туда, откуда был вызов просмотра фото
                    if (index == 0) {
                      Navigator.pop(context);
                    }

                    // Кнопка "Карта" перемещает на экран карты через провайдер
                    else if (index == 1) {

                      final nav = context.read<NavigationProvider>();

                      // Если фото с координатами — запоминаем их
                      if (widget.image.latitude != null && widget.image.longitude != null) {
                        nav.pendingCenter = LatLng(widget.image.latitude!, widget.image.longitude!);
                      }

                      // Переключаемся на экран карты
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        nav.setIndex(1);
                      });

                      // Просто закрываем экран
                      Navigator.pop(context);
                    }
                  },

                  items: const [
                    NavButtonData(icon: Icons.arrow_back_rounded, label: 'Назад', ),
                    NavButtonData(icon: Icons.map_rounded, label: 'Карта'),
                  ],
                ),
              ),
            ),
          ),


          // Информация об изображении
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: MediaQuery.of(context).padding.top + 16,
            left: 32,
            right: 32,

            child: IgnorePointer(
              ignoring: !_uiVisible,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _uiVisible ? 1 : 0,
                child: PhotoInfoHeader(image: widget.image,),
              ),
            ),

          ),
        ],
      ),
    );
  }
}

// Класс для виджета отображения информации об изображении
class PhotoInfoHeader extends StatelessWidget {

  // Просматриваемое изображение
  final GalleryImage image;

  const PhotoInfoHeader({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    // Дата и время съемки
    final hasDateTaken = image.dateTaken != null;
    final dateTakenStr = hasDateTaken
        ? DateFormat('d MMMM yyyy', 'ru_RU').format(image.dateTaken!)
        : 'Неизвестно';
    final timeTakenStr = hasDateTaken
        ? DateFormat('HH:mm').format(image.dateTaken!)
        : '';

    // Дата создания файла с поправкой на МСК (+3 часа)
    final fileCreated = File(image.file.path).lastModifiedSync().add(const Duration(hours: 3));
    final fileCreatedStr = DateFormat('d MMMM yyyy', 'ru_RU').format(fileCreated);
    final fileTimeStr = DateFormat('HH:mm').format(fileCreated);

    // Есть ли координаты
    final hasCoordinates = image.latitude != null && image.longitude != null;


    return IgnorePointer(
      ignoring: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB((0.1 * 255).round(), 158, 158, 158),
                  Color.fromARGB((0.3 * 255).round(), 158, 158, 158),
                  Color.fromARGB((0.1 * 255).round(), 158, 158, 158),
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
              border: Border.all(
                color: Color.fromARGB((0.35 * 255).round(), 255, 255, 255),
                width: 1,
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                // Дата и время съемки
                Text(
                  image.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Дата и время создания файла
                Text(
                  'Файл создан: $fileCreatedStr, $fileTimeStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,

                  ),
                ),

                Text(
                  hasDateTaken
                      ? 'Дата съёмки: $dateTakenStr, $timeTakenStr'
                      : 'Дата съёмки: Неизвестно',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  hasCoordinates
                      ? 'Ш: ${image.latitude!.toStringAsFixed(6)}, Д: ${image.longitude!.toStringAsFixed(6)}'
                      : 'Координаты отсутствуют',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasCoordinates ? Colors.black87 : Colors.redAccent,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
