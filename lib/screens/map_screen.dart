import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';


// Локальные импорты
import '../widgets/section_header.dart';
import '../widgets/action_menu.dart';
import '../providers/image_provider.dart';
import '../screens/photo_view_screen.dart';
import '../providers/navigation_provider.dart';



/// Класс экрана карты с фотографиями
class MapScreen extends StatefulWidget {

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  // Контроллер для управления картой (движение, приближение и т.д.)
  final MapController _mapController = MapController();

  // Начальные координаты и зум (Ульяновск)
  final LatLng _homeCenter = LatLng(54.3182, 48.3838);
  final double _homeZoom = 7.0;

  // Храним id выбранного маркера
  String? _selectedImagePath;



  @override
  Widget build(BuildContext context) {

    // Получаем провайдер галереи
    final gallery = context.watch<GalleryProvider>();

    final nav = context.watch<NavigationProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nav.pendingCenter != null) {
        _mapController.move(nav.pendingCenter!, _homeZoom);
        nav.pendingCenter = null; // очистка после перехода
      }
    });


    return Scaffold(
      body: Stack(
        children: [

          // Слой карты
          FlutterMap(
            mapController: _mapController,

            // Параметры карты
            options: MapOptions(

              // Начальный центр и приближение
              initialCenter: _homeCenter,
              initialZoom: _homeZoom,

              // Предельные значения приближения
              minZoom: 2,
              maxZoom: 19,

              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-85, -180),
                  const LatLng(85, 180),
                ),
              ),

              // Отключение возможности поворота карты
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),

            ),

            children: [

              // Слой подложки (OpenStreetMap)
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.geoalbum.app',

              ),

              // ====== Слой с маркерами фото ======
              if (!gallery.loading && !gallery.loadError)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(

                  maxClusterRadius: 100, // радиус объединения
                  disableClusteringAtZoom: 15, // выше этого зума раскладываем маркеры
                  size: const Size(40, 40),

                  // только фото с координатами
                  markers: gallery.images
                      .where((img) => img.latitude != null && img.longitude != null)
                      .map((img) {
                    final isSelected = _selectedImagePath == img.file.path;

                    return Marker(
                      key: ValueKey(img.file.path.hashCode),
                      point: LatLng(img.latitude!, img.longitude!),
                      width: isSelected ? 120 : 40,
                      height: isSelected ? 120 : 40,
                      child: GestureDetector(
                        onTap: () async {

                          // открываем экран просмотра фото и ждём возврата
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoViewScreen(
                                image: img,
                                previousIndex: context.read<NavigationProvider>().currentIndex,
                              ),
                            ),
                          );

                          // если вернули координаты — центрируем карту
                          if (result is LatLng) {
                            _mapController.move(result, _homeZoom);
                          }
                        },

                        onDoubleTap: () {
                          setState(() {
                            _selectedImagePath =
                            (_selectedImagePath == img.file.path) ? null : img.file.path;
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isSelected
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(img.file, fit: BoxFit.cover),
                          )
                              : const Icon(
                            Icons.location_on_rounded,
                            color: Colors.green,
                            size: 42,
                          ),
                        ),
                      ),
                    );
                  }).toList(),


                  builder: (context, markers) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color.fromARGB((0.7 * 255).toInt(), 0, 128, 0),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                ),

            ],
          ),

          // ===== Заголовок =====
          const SectionHeader(title: 'Карта фотографий'),

          // Кнопки приближения/отдаления — справа по центру
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomActionMenu(
                    orientation: Axis.vertical, // или Axis.horizontal
                    buttonSize: 34,
                    spacing: 16,
                    items: [
                      MenuItem(
                        Icons.add_rounded,
                        onTap: () {
                          final zoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            zoom + 1,
                          );
                        },
                      ),
                      MenuItem(
                        Icons.remove_rounded,
                        onTap: () {
                          final zoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            zoom - 1,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Кнопка центрирования карты на г. Ульяновск с возвратом масштаба
                  CustomActionMenu(
                    orientation: Axis.vertical,
                    buttonSize: 44,
                    items: [
                      MenuItem(
                        Icons.home_rounded,
                        onTap: () {
                          _mapController.move(_homeCenter, _homeZoom);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
