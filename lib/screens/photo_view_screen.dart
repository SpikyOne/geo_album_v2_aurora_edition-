import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper_aurora/image_cropper_aurora.dart';

// Локальные импорты
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/image_data_model.dart';
import '../widgets/action_menu.dart';
import '../providers/image_provider.dart';

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
  // Отображать ли интерфейс
  bool _uiVisible = true;

  // Находимся ли в режиме редактирования
  bool _isEditing = false;

  // Переключение режима экрана
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _uiVisible = true;
    });
  }

  Future<void> _handleRename() async {
    final newName = await showDialog<String>(
      context: context,
      barrierColor: Color.fromARGB((0.05 * 255).round(), 0, 0, 0),
      builder:
          (context) => SimpleRenameDialog(currentName: widget.image.fileName),
    );

    if (newName != null && newName != widget.image.fileName) {
      _performRename(newName);
    }
  }

  Future<void> _performRename(String newName) async {
    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Получаем провайдер и переименовываем файл
      final galleryProvider = Provider.of<GalleryProvider>(
        context,
        listen: false,
      );
      final success = await galleryProvider.renameImage(widget.image, newName);

      // Закрываем индикатор
      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        // Получаем обновленное изображение
        final updatedImage = galleryProvider.images.firstWhere(
          (img) => img.fileName == newName,
          orElse: () => widget.image.copyWith(fileName: newName),
        );

        // Показываем уведомление об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Файл переименован в: $newName'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Переходим к просмотру обновленного фото
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => PhotoViewScreen(
                  image: updatedImage,
                  previousIndex: widget.previousIndex,
                ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка переименования файла'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Ошибка переименования: $e');
    }
  }

  Future<void> _handleCrop() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.image.file.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AuroraUiSettings(
            context: context,

            // === ЦВЕТА СЕТКИ ===

            // Основной цвет сетки - зелёный
            gridColor: Colors.green,

            // Полупрозрачный светло-серый фон (почти белый)
            scrimColor: const Color.fromARGB(150, 240, 240, 240),

            // Внутренние линии сетки - более светлый зелёный
            gridInnerColor: Colors.greenAccent.shade400,

            // Уголки - яркий зелёный
            gridCornerColor: Colors.green.shade700,

            // === КНОПКИ ПОВОРОТА В СТИЛЕ CustomActionMenu ===
            hasLeftRotation: true,
            hasRightRotation: true,

            rotateLeftIcon: Icon(
              Icons.rotate_left,
              size: 28,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(1, 1),
                ),
              ],
            ),

            rotateRightIcon: Icon(
              Icons.rotate_right,
              size: 28,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(1, 1),
                ),
              ],
            ),

            rotateLeftButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black87),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              elevation: WidgetStateProperty.all(4),
              shadowColor: WidgetStateProperty.all(
                const Color.fromARGB(89, 0, 0, 0),
              ),
              overlayColor: WidgetStateProperty.all(
                Color.fromARGB((0.1 * 255).round(), 255, 255, 255),
              ),
            ),

            rotateRightButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black87),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              elevation: WidgetStateProperty.all(4),
              shadowColor: WidgetStateProperty.all(
                const Color.fromARGB(89, 0, 0, 0),
              ),
              overlayColor: WidgetStateProperty.all(
                Color.fromARGB((0.1 * 255).round(), 255, 255, 255),
              ),
            ),

            // === КНОПКА СОХРАНЕНИЯ В СТИЛЕ CustomActionMenu ===
            cropButtonText: const Text(
              'Обрезать',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            cropButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black87),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              elevation: WidgetStateProperty.all(6),
              shadowColor: WidgetStateProperty.all(
                const Color.fromARGB(89, 0, 0, 0),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              overlayColor: WidgetStateProperty.all(
                Color.fromARGB((0.1 * 255).round(), 255, 255, 255),
              ),
            ),

            // === ФОН ДИАЛОГА С БЛЮРОМ КАК В SectionHeader ===
            dialogBackgroundColor: const Color.fromARGB(200, 248, 249, 250),

            // === ИНДИКАТОР ЗАГРУЗКИ ===
            loadingPlaceholder: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(25, 158, 158, 158),
                    const Color.fromARGB(76, 158, 158, 158),
                    const Color.fromARGB(25, 158, 158, 158),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color.fromARGB(89, 255, 255, 255),
                  width: 1,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                strokeWidth: 3,
              ),
            ),

            // === НАСТРОЙКИ СЕТКИ ===
            paddingSize: 16,
            touchSize: 44,
            gridCornerSize: 28,
            showCorners: true,
            gridThinWidth: 1.5,
            gridThickWidth: 2.5,
            alwaysShowThirdLines: true,
            minimumImageSize: 80.0,

            // === РАЗМЕРЫ ДИАЛОГА ===
            dialogWidthScale: 0.95,
            dialogHeightScale: 0.88,

            // === ПУТЬ ФАЙЛА ===
            showSourceImagePath: false, // Скрываем чтобы не портить дизайн
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        final galleryProvider = Provider.of<GalleryProvider>(
          context,
          listen: false,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        final success = await galleryProvider.saveCroppedImage(
          widget.image,
          File(croppedFile.path),
        );

        if (mounted) Navigator.of(context).pop();

        if (success && mounted) {

          // Принудительно обновляем всю галерею
        await galleryProvider.refreshGallery();

          await Future.delayed(const Duration(milliseconds: 300));

          // Получаем обновленное изображение из провайдера
          final updatedImages = galleryProvider.images.where(
          (img) => img.file.path == widget.image.file.path
        ).toList();
        
        if (updatedImages.isNotEmpty) {
          final updatedImage = updatedImages.first;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото успешно обрезано'),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PhotoViewScreen(
                    image: updatedImage,
                    previousIndex: widget.previousIndex,
                  ),
            ),
          );
        } else {
          // Если изображение не найдено, возвращаемся в галерею
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото обрезано, возврат в галерею'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        }
        else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при сохранении обрезанного фото'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        }
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обрезке: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Error cropping image: $e');
    }
  }

  void _handleExit() {
    _toggleEditMode(); // Выходим из режима редактирования
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // Основное изображение
          _buildImageViewer(),

          // Режим ПРОСМОТРА
          if (!_isEditing) ..._buildViewMode(),

          // Режим РЕДАКТИРОВАНИЯ
          if (_isEditing) ..._buildEditMode(),
        ],
      ),
    );
  }

  // Отображение самого изображения с возможностью масштабирования
  Widget _buildImageViewer() {
    return GestureDetector(
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
    );
  }

  // Виджеты для режима ПРОСМОТРА
  List<Widget> _buildViewMode() {
    return [
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
                  if (widget.image.latitude != null &&
                      widget.image.longitude != null) {
                    nav.pendingCenter = LatLng(
                      widget.image.latitude!,
                      widget.image.longitude!,
                    );
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
                NavButtonData(icon: Icons.arrow_back_rounded, label: 'Назад'),
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
            child: PhotoInfoHeader(image: widget.image),
          ),
        ),
      ),

      // Кнопки редактирования/открыть в другом приложении — справа по центру
      AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.centerRight,

        child: IgnorePointer(
          ignoring: !_uiVisible,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _uiVisible ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Кнопка с приглашением к редактирования
                  CustomActionMenu(
                    orientation: Axis.vertical,
                    buttonSize: 44,
                    items: [
                      MenuItem(Icons.edit_rounded, onTap: _toggleEditMode),

                      MenuItem(
                        Icons.open_in_new_rounded,
                        onTap: () {
                          _openInOtherApps(widget.image.file);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // Виджеты для режима РЕДАКТИРОВАНИЯ
  List<Widget> _buildEditMode() {
    return [
      // Нижнее меню редактирования (показывается только в режиме редактирования)
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(
                  context,
                ).padding.bottom, 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Основные действия
              CustomActionMenu(
                orientation: Axis.horizontal,
                buttonSize: 44,
                items: [
                  MenuItem(
                    Icons.drive_file_rename_outline_rounded,
                    label: 'Переименовать',
                    onTap: _handleRename,
                  ),

                  MenuItem(
                    Icons.crop_rotate_rounded,
                    label: 'Обрезать',
                    onTap: _handleCrop,
                  ),
                ],
              ),

              // Кнопка сохранения
              CustomActionMenu(
                orientation: Axis.horizontal,
                buttonSize: 48,
                items: [
                  MenuItem(
                    Icons.save_rounded,
                    label: 'Выход',
                    onTap: _handleExit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

/// Класс для виджета переименования изображения
class SimpleRenameDialog extends StatefulWidget {
  final String currentName;

  const SimpleRenameDialog({super.key, required this.currentName});

  @override
  State<SimpleRenameDialog> createState() => _SimpleRenameDialogState();
}

class _SimpleRenameDialogState extends State<SimpleRenameDialog> {
  late TextEditingController _controller;
  String? _errorText;
  late String _fileExtension;

  @override
  void initState() {
    super.initState();
    // Получаем расширение файла
    _fileExtension = _getFileExtension(widget.currentName);
    // Убираем расширение из имени для редактирования
    final fileNameWithoutExtension = _removeFileExtension(widget.currentName);
    _controller = TextEditingController(text: fileNameWithoutExtension);

    // Слушаем изменения текста для валидации
    _controller.addListener(_validateInput);
  }

  String _getFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(dotIndex) : '';
  }

  String _removeFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
  }

  void _validateInput() {
    final text = _controller.text.trim();

    setState(() {
      if (text.isEmpty) {
        _errorText = 'Имя не может быть пустым';
      } else if (text.contains('/') ||
          text.contains('\\') ||
          text.contains(':') ||
          text.contains('*') ||
          text.contains('?') ||
          text.contains('"') ||
          text.contains('<') ||
          text.contains('>') ||
          text.contains('|')) {
        _errorText = 'Имя содержит недопустимые символы';
      } else {
        _errorText = null;
      }
    });
  }

  String _getFullFileName() {
    return '${_controller.text.trim()}$_fileExtension';
  }

  bool get _isValid => _errorText == null && _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
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
              border: Border.all(
                color: Color.fromARGB((0.35 * 255).round(), 255, 255, 255),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок в стиле SectionHeader
                Text(
                  'Новое имя',
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

                const SizedBox(height: 20),

                // Поле ввода
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _errorText != null ? Colors.red : Colors.grey,
                        width: _errorText != null ? 2 : 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _errorText != null ? Colors.red : Colors.grey,
                        width: _errorText != null ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _errorText != null ? Colors.red : Colors.blue,
                        width: _errorText != null ? 2 : 2,
                      ),
                    ),
                    errorText: _errorText,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixText: _fileExtension,
                    suffixStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  autofocus: true,
                  onChanged: (_) => _validateInput(),
                ),

                const SizedBox(height: 28),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isValid
                                ? () =>
                                    Navigator.pop(context, _getFullFileName())
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isValid ? Colors.black87 : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'ОК',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final dateTakenStr =
        hasDateTaken
            ? DateFormat('d MMMM yyyy', 'ru_RU').format(image.dateTaken!)
            : 'Неизвестно';
    final timeTakenStr =
        hasDateTaken ? DateFormat('HH:mm').format(image.dateTaken!) : '';

    // Дата создания файла с поправкой на МСК (+3 часа)
    final fileCreated = File(
      image.file.path,
    ).lastModifiedSync().add(const Duration(hours: 3));
    final fileCreatedStr = DateFormat(
      'd MMMM yyyy',
      'ru_RU',
    ).format(fileCreated);
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

// Функция для открытия изображения в других приложениях
Future<void> _openInOtherApps(File imageFile) async {
  try {
    final String fileUri = 'file://${imageFile.path}';

    if (!await launchUrl(Uri.parse(fileUri))) {
      throw Exception('Не удалось открыть: $fileUri');
    }
  } on PlatformException {
    throw "Failed to open";
  }
}
