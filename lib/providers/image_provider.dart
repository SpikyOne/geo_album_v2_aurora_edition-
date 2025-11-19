import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Локальные импорты
import '../models/image_data_model.dart';
import '../services/exif_loader.dart';

/// Класс сервиса загрузки и кеширования изображений с использованием ChangeNotifier
class GalleryProvider extends ChangeNotifier {
  GalleryProvider._privateConstructor();
  static final GalleryProvider instance = GalleryProvider._privateConstructor();

  final Map<String, GalleryImage> _memoryCache = {};
  final List<GalleryImage> _images = [];

  bool _loading = false;
  bool _loadError = false;
  bool _initialized = false; // чтобы не грузить повторно

  List<GalleryImage> get images => _images;
  bool get loading => _loading;
  bool get loadError => _loadError;
  bool get initialized => _initialized;

  /// Переименование файла изображения
  Future<bool> renameImage(GalleryImage oldImage, String newFileName) async {
    try {
      final File oldFile = oldImage.file;
      final String oldPath = oldFile.path;
      final String directory = p.dirname(oldPath);
      final String newPath = p.join(directory, newFileName);

      // Проверяем, не существует ли уже файл с таким именем
      if (await File(newPath).exists()) {
        debugPrint('Файл с именем $newFileName уже существует');
        return false;
      }

      // Переименовываем файл
      await oldFile.rename(newPath);

      // Обновляем кеш и список изображений
      _memoryCache.remove(oldPath);

      final newImage = GalleryImage(
        file: File(newPath),
        fileName: newFileName,
        dateTaken: oldImage.dateTaken,
        latitude: oldImage.latitude,
        longitude: oldImage.longitude,
        folderName: oldImage.folderName,
      );

      _memoryCache[newPath] = newImage;

      // Находим и заменяем изображение в списке
      final index = _images.indexWhere((img) => img.file.path == oldPath);
      if (index != -1) {
        _images[index] = newImage;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка переименования файла: $e');
      return false;
    }
  }

  /// Инициализация галереи: проверка разрешений + загрузка
  Future<void> initGallery({String? dirPath}) async {
    if (_initialized) return; // уже загружено

    _loading = true;
    _loadError = false;
    notifyListeners();

    await _loadImages(dirPath: dirPath);
    _initialized = true;
  }

  /// Методы получения изображений из директории (рекурсивно)
  Future<void> _loadImages({String? dirPath}) async {
    try {
      _loading = true;
      _loadError = false;
      notifyListeners();

      // Определение сканируемой директории с изображениями (по умолчанию Pictures)
      Directory directory;
      if (dirPath != null) {
        directory = Directory(dirPath);
      } else {
        final List<Directory>? picturesDirs =
            await getExternalStorageDirectories(
              type: StorageDirectory.pictures,
            );

        if (picturesDirs == null || picturesDirs.isEmpty) {
          throw Exception('Could not access Pictures directory');
        }

        directory = picturesDirs[0];
      }

      if (!await directory.exists()) {
        _images.clear();
        _loading = false;
        notifyListeners();
        return;
      }

      _images.clear();

      // Поиск изображений
      await for (var entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File &&
            (entity.path.toLowerCase().endsWith('.jpg') ||
                entity.path.toLowerCase().endsWith('.jpeg') ||
                entity.path.toLowerCase().endsWith('.png'))) {
          final metadata = await ExifLoader.extractExif(entity);
          final folderName = p.basename(p.dirname(entity.path));

          final galleryImage = GalleryImage(
            file: entity,
            fileName: p.basename(entity.path),
            dateTaken: metadata['date'],
            latitude: metadata['lat'],
            longitude: metadata['lon'],
            folderName: folderName,
          );

          _memoryCache[entity.path] = galleryImage;
          _images.add(galleryImage);
        }
      }

      // Сортировка по дате изменения/создания (сначала новые)
      images.sort((a, b) {
        final aTime = a.dateTaken ?? a.file.statSync().modified;
        final bTime = b.dateTaken ?? b.file.statSync().modified;
        return bTime.compareTo(aTime);
      });

      _loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки изображений: $e');
      _images.clear();
      _loading = false;
      _loadError = true;
      notifyListeners();
    }
  }
}
