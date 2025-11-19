import 'package:image_cropper_aurora/image_cropper_aurora.dart';

class ImageCropperRegistrar {
  static void register() {
    // Регистрируем Aurora implementation
    ImageCropperAurora.registerWith();
  }
}