import 'package:flutter/material.dart';

class PlantListNotifier extends ChangeNotifier {
  late List<String> plants = List.generate(10, (index) => 'Plant ${index + 1}');

  void removePlant(int index) {
    if (index >= 0 && index < plants.length) {
      plants.removeAt(index);
      notifyListeners();
    }
  }

  late String imageUrl = 'assets/images/leaf.png';
  late int itemCount = 10;

  void setImageUrl(String newImageUrl) {
    imageUrl = newImageUrl;
    notifyListeners();
  }

  void setItemCount(int newItemCount) {
    itemCount = newItemCount;
    notifyListeners();
  }
}
