import 'package:flutter/material.dart';

class PlantListNotifier extends ChangeNotifier {
  late List<String> plants = List.generate(10, (index) => 'Plant ${index + 1}');
  late String _imageUrl = 'assets/images/leaf.png';
  late int _itemCount = 10;
  late String listId; // Add listId property
  late String listName; // Add listName property

  // late String imageUrl = 'assets/images/leaf.png';
  // late int itemCount = 10;
  String get imageUrl => _imageUrl;
  int get itemCount => _itemCount;

  void removePlant(int index) {
    if (index >= 0 && index < plants.length) {
      plants.removeAt(index);
      notifyListeners();
    }
  }

  void setImageUrl(String newImageUrl) {
    _imageUrl = newImageUrl;
    notifyListeners();
  }

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}
