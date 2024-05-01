import 'package:flutter/material.dart';

// a notifier that sets the number of plants in a saved list
class PlantDetailsNotifier extends ChangeNotifier {
  late int _itemCount = 0;
  int get itemCount => _itemCount;

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}
