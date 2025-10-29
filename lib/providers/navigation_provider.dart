import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';



/// Провайдер навигации для управления текущим выбранным экраном приложения.
/// Использует ChangeNotifier для оповещения слушателей о смене индекса.
class NavigationProvider extends ChangeNotifier {

  /// Текущий индекс выбранного экрана
  int _currentIndex = 0;

  /// Центрирование карты
  LatLng? pendingCenter;


  /// Геттер для текущего индекса
  int get currentIndex => _currentIndex;

  /// Метод для изменения текущего индекса
  void setIndex(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

}