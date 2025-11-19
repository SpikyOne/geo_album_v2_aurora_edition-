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




  // Метод для создания копии с изменёнными полями
  GalleryImage copyWith({
    File? file,
    String? fileName,
    DateTime? dateTaken,
    double? latitude,
    double? longitude,
    String? folderName,
  }) {
    return GalleryImage(
      file: file ?? this.file,
      fileName: fileName ?? this.fileName,
      dateTaken: dateTaken ?? this.dateTaken,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      folderName: folderName ?? this.folderName,
    );
  }

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