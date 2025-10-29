import 'package:flutter/material.dart';

// Локальные импорты
import '../models/image_data_model.dart';



/// Класс для миниатюры изображения на экране галереи
class PhotoTile extends StatelessWidget {

  // Отображаемое изображение
  final GalleryImage image;

  final VoidCallback? onTap;


  const PhotoTile({super.key, required this.image, this.onTap});


  @override
  Widget build(BuildContext context) {

    // Есть ли у изображения geotag
    final hasGeo = image.latitude != null && image.longitude != null;


    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB((0.15 * 255).round(), 0, 0, 0),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),

          child: Stack(
            children: [
              Image.file(
                image.file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Ошибка при загрузке изображения: $error');
                  return const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.black54,
                  );
                },
              ),

              // Кружочек в левом нижнем углу, если нет geotag
              if (!hasGeo)
                const Positioned(
                  bottom: 4,
                  left: 4,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.orange,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
