import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';

/// Класс для извлечения EXIF-метаданных (дата, GPS)
class ExifLoader {

  /// Извлекает дату и координаты GPS из изображения
  static Future<Map<String, dynamic>> extractExif(File file) async {
    try {

      final bytes = await file.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      DateTime? date;
      double? lat;
      double? lon;

      // -------------------------------
      // Извлечение даты съёмки
      // -------------------------------
      final dateTag = tags['EXIF DateTimeOriginal']?.printable ??
          tags['Image DateTime']?.printable ??
          tags['EXIF DateTimeDigitized']?.printable;

      if (dateTag != null && dateTag.isNotEmpty) {
        final normalized = dateTag.replaceAll(':', '-').replaceFirst(' ', 'T');
        date = DateTime.tryParse(normalized);
      }

      // -------------------------------
      // Извлечение GPS координат
      // -------------------------------
      final latObj = tags['GPS GPSLatitude']?.values;
      final lonObj = tags['GPS GPSLongitude']?.values;
      final latRef = (tags['GPS GPSLatitudeRef']?.printable)?.trim();
      final lonRef = (tags['GPS GPSLongitudeRef']?.printable)?.trim();

      lat = _parseGpsValues(latObj);
      lon = _parseGpsValues(lonObj);

      if (lat != null && latRef == 'S') lat = -lat;
      if (lon != null && lonRef == 'W') lon = -lon;

      return {'date': date, 'lat': lat, 'lon': lon};
    }

    catch (e, st) {
      debugPrint('Ошибка при чтении EXIF: $e\n$st');
      return {'date': null, 'lat': null, 'lon': null};
    }
  }

  /// Конвертация GPS-значений из EXIF (IfdRatios → double)
  static double? _parseGpsValues(dynamic obj) {
    if (obj == null) return null;

    try {
      // Преобразуем IfdRatios в список
      List<dynamic> values;
      if (obj is IfdRatios) { values = obj.toList(); }
      else if (obj is List) { values = obj; }
      else { debugPrint('Неизвестный формат GPS: $obj'); return null; }

      if (values.length < 3) return null;

      double toDouble(dynamic val) {
        if (val is num) return val.toDouble();
        if (val is Ratio) return val.numerator / val.denominator;
        if (val.toString().contains('/')) {
          final parts = val.toString().split('/');
          final nume = double.tryParse(parts[0]) ?? 0;
          final deno = double.tryParse(parts[1]) ?? 1;
          return nume / deno;
        }
        return double.tryParse(val.toString()) ?? 0.0;
      }

      final deg = toDouble(values[0]);
      final min = toDouble(values[1]);
      final sec = toDouble(values[2]);

      return deg + (min / 60.0) + (sec / 3600.0);
    } catch (e) {
      debugPrint('Ошибка при парсинге GPS: $e');
      return null;
    }
  }
}
