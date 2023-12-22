import 'package:flutter/material.dart';

class PlantDetailsNotifier extends ChangeNotifier {
  late int _itemCount = 0;
  int get itemCount => _itemCount;

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}
