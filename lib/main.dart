import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Локальные импорты
import '../app.dart';
import '../providers/image_provider.dart';



void main() async {


  await initializeDateFormatting('ru_RU', null);

  WidgetsFlutterBinding.ensureInitialized();



  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  // Сразу инициализируем провайдер
  await GalleryProvider.instance.initGallery();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GalleryProvider.instance,
      child: const MyApp(),
    ),
  );
}
