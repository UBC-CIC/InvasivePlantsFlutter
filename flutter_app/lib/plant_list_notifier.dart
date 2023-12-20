import 'package:flutter/material.dart';

class PlantListNotifier extends ChangeNotifier {
  late List<String> plants = [];

  late int _itemCount = 0;
  late String listId;
  late String listName;

  int get itemCount => _itemCount;

  void removePlant(int index) {
    if (index >= 0 && index < plants.length) {
      plants.removeAt(index);
      notifyListeners();
    }
  }

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}
