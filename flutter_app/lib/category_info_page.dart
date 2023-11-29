// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'plant_info_from_category_page.dart';
import 'package:provider/provider.dart';
import 'my_plants_page.dart';
import 'plant_list_notifier.dart';

// class PlantListNotifier extends ChangeNotifier {
//   List<String> plants = List.generate(10, (index) => 'Plant ${index + 1}');

//   void removePlant(int index) {
//     if (index >= 0 && index < plants.length) {
//       plants.removeAt(index);
//       notifyListeners();
//     }
//   }
// }

class CategoryInfoPage extends StatefulWidget {
  final String listId;
  final String categoryTitle;

  const CategoryInfoPage(
      {super.key, required this.categoryTitle, required this.listId});

  @override
  _CategoryInfoPageState createState() => _CategoryInfoPageState();
}

class _CategoryInfoPageState extends State<CategoryInfoPage> {
  late PlantListNotifier plantListNotifier;
  late String imageUrl; // Image URL variable

  @override
  void initState() {
    super.initState();
    plantListNotifier =
        context.read<UserListsNotifier>().getOrCreateList(widget.listId);
    imageUrl = context.read<PlantDetailsNotifier>().imageUrl;
  }

  @override
  void dispose() {
    // Don't dispose of the notifier here to prevent early disposal
    super.dispose();
  }

  void loadPlantsFromDataSource(String listId) {
    // Load plants for the provided listId and assign them to plantListNotifier
    // You might fetch data from a database or any other storage mechanism here
    // For demonstration, let's assume initializing with dummy data
    List<String> plants = List.generate(10, (index) => 'Plant ${index + 1}');
    plantListNotifier.plants = plants;
  }

  @override
  Widget build(BuildContext context) {
    final plantDetailsNotifier = Provider.of<PlantDetailsNotifier>(context);

    return ChangeNotifierProvider.value(
      value: plantListNotifier,
      builder: (context, child) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              widget.categoryTitle,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              onPressed: () {
                plantDetailsNotifier.setImageUrl(imageUrl);
                plantDetailsNotifier
                    .setItemCount(plantListNotifier.plants.length);
                Navigator.pop(context, {
                  'imageUrl': imageUrl,
                  'itemCount': plantListNotifier.plants.length
                });
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.lightBlue),
                  ),
                ),
              ),
            ],
          ),
          body: Consumer2<PlantDetailsNotifier, PlantListNotifier>(
            builder: (context, details, plantList, _) {
              imageUrl = details.imageUrl;

              return ListView.builder(
                itemCount: plantList.plants.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         const PlantInfoFromCategoryPage(
                          //       speciesObject: {},
                          //     ),
                          //   ),
                          // );
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plantList.plants[index],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Scientific Name',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Plant'),
                                          content: Text(
                                            'Are you sure you want to delete ${plantList.plants[index]}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                plantList.removePlant(index);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
