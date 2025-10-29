import 'dart:io';



/// Класс-обёртка для изображения из Pictures, хранящий его метаданные
class GalleryImage {

  // Файл изображения
  final File file;

  // Название файла
  final String fileName;

  // Дата создания изображения
  final DateTime? dateTaken;

  // Широта
  final double? latitude;

  // Долгота
  final double? longitude;

  // Название папки, в которой хранилось изображение в папке Pictures
  final String folderName;

  GalleryImage({
    required this.file,
    required this.fileName,
    required this.dateTaken,
    required this.latitude,
    required this.longitude,
    required this.folderName,
  });

  @override
  String toString() {
    return 'GalleryImage(\n'
        '  fileName: $fileName,\n'
        '  folder: $folderName,\n'
        '  path: ${file.path},\n'
        '  dateTaken: ${dateTaken ?? "Unknown"},\n'
        '  location: ${latitude != null && longitude != null ? "$latitude, $longitude" : "Unknown"}\n'
        ')';
  }
}