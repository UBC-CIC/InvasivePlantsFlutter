import 'package:flutter/material.dart';
import 'package:flutter_app/category_info_page.dart';
import 'camera_page.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'plant_list_notifier.dart';

class UserListsNotifier extends ChangeNotifier {
  Map<String, PlantListNotifier> userLists = {};

  void addNewList(String listName) {
    final newListId = listName; // Create a unique ID for the list
    userLists[newListId] =
        PlantListNotifier(); // Initialize the PlantListNotifier
    notifyListeners();
  }

  void removeList(String listId) {
    userLists.remove(listId);
    notifyListeners();
  }

  PlantListNotifier getOrCreateList(String listId) {
    return userLists.putIfAbsent(listId, () => PlantListNotifier());
  }
}

// class PlantListNotifier extends ChangeNotifier {
//   late String _imageUrl = 'assets/images/leaf.png';
//   late int _itemCount = 10;

//   String get imageUrl => _imageUrl;
//   int get itemCount => _itemCount;

//   void setImageUrl(String newImageUrl) {
//     _imageUrl = newImageUrl;
//     notifyListeners();
//   }

//   void setItemCount(int newItemCount) {
//     _itemCount = newItemCount;
//     notifyListeners();
//   }
// }

class PlantDetailsNotifier extends ChangeNotifier {
  late String _imageUrl =
      'assets/images/swordfern1.jpeg'; // Initialize with default value
  late int _itemCount = 10; // Initialize with default value

  String get imageUrl => _imageUrl;

  int get itemCount => _itemCount;

  // Methods to update values
  void setImageUrl(String newImageUrl) {
    _imageUrl = newImageUrl;
    notifyListeners();
  }

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}

class MyPlantsPage extends StatefulWidget {
  const MyPlantsPage({super.key});

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {
  @override
  Widget build(BuildContext context) {
    final plantDetailsNotifier = Provider.of<PlantDetailsNotifier>(context);

    String imageUrl = plantDetailsNotifier.imageUrl;
    int itemCount = plantDetailsNotifier.itemCount;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MY PLANTS',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String newListName = '';
                      return AlertDialog(
                        title: const Text('Enter Your List Name:'),
                        content: TextField(
                          onChanged: (text) {
                            newListName = text;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (newListName.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    content: const Text('Please enter a name'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                final userListsNotifier =
                                    Provider.of<UserListsNotifier>(context,
                                        listen: false);
                                userListsNotifier.addNewList(newListName);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              'Create',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add, color: Colors.lightBlue),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<UserListsNotifier>(
              builder: (context, userListsNotifier, child) {
                final userLists = userListsNotifier.userLists.keys.toList();
                // final listId = 'list_${userLists.keys.elementAt(index)}'; // Update this line
                // final keys = userLists.keys.toList(); // Extract keys to a list

                if (userLists.isEmpty) {
                  return Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Click ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: '+',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 25,
                            ),
                          ),
                          TextSpan(
                            text: ' to create a list of plants',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: userLists.length,
                  itemBuilder: (context, index) {
                    final listId = userLists[index];
                    final plantListNotifier =
                        userListsNotifier.getOrCreateList(listId);

                    // Fetch individual values for each list
                    String imageUrl = plantListNotifier.imageUrl;
                    int itemCount = plantListNotifier.itemCount;

                    return Container(
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
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => plantListNotifier,
                                child: CategoryInfoPage(
                                  listId: listId,
                                  categoryTitle: listId,
                                ),
                              ),
                            ),
                          );

                          if (result != null &&
                              result is Map<String, dynamic>) {
                            // Update the imageUrl and itemCount for the specific list
                            plantListNotifier.setImageUrl(result['imageUrl']);
                            plantListNotifier.setItemCount(result['itemCount']);
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: AssetImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    listId,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text(
                                        '# of plants: ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.lightBlue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete List'),
                                        content: Text(
                                          'Are you sure you want to delete $listId?',
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
                                              userListsNotifier
                                                  .removeList(listId);
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(37)),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            selectedFontSize: 0.0,
            unselectedFontSize: 0.0,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_rounded,
                  size: 40,
                  color: Color.fromARGB(255, 118, 118, 118),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined, size: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.bookmark,
                  size: 40,
                  color: Colors.blue,
                ),
                label: '',
              ),
            ],
            onTap: (int index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraPage(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
