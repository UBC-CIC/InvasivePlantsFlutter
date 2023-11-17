import 'package:flutter/material.dart';
import 'package:flutter_app/category_info_page.dart';
import 'camera_page.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';

class UserListsNotifier extends ChangeNotifier {
  List<String> userLists = [];

  void addNewList(String listName) {
    userLists.add(listName);
    notifyListeners();
  }

  void removeList(int index) {
    if (index >= 0 && index < userLists.length) {
      userLists.removeAt(index);
      notifyListeners();
    }
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
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          // Container(
          //   margin: const EdgeInsets.fromLTRB(120, 0, 120, 10),
          //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (context) {
          //           String newListName = '';
          //           return AlertDialog(
          //             title: const Text('Enter Your List Name:'),
          //             content: TextField(
          //               onChanged: (text) {
          //                 newListName = text;
          //               },
          //             ),
          //             actions: <Widget>[
          //               TextButton(
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                 },
          //                 child: const Text(
          //                   'Cancel',
          //                   style: TextStyle(color: Colors.grey),
          //                 ),
          //               ),
          //               TextButton(
          //                 onPressed: () {
          //                   if (newListName.trim().isEmpty) {
          //                     ScaffoldMessenger.of(context).showSnackBar(
          //                       SnackBar(
          //                         duration: const Duration(milliseconds: 1000),
          //                         behavior: SnackBarBehavior.floating,
          //                         shape: RoundedRectangleBorder(
          //                           borderRadius: BorderRadius.circular(10),
          //                         ),
          //                         content: const Text('Please enter a name'),
          //                         backgroundColor: Colors.red,
          //                       ),
          //                     );
          //                   } else {
          //                     final userListsNotifier =
          //                         Provider.of<UserListsNotifier>(context,
          //                             listen: false);
          //                     userListsNotifier.addNewList(newListName);
          //                     Navigator.of(context).pop();
          //                   }
          //                 },
          //                 child: const Text(
          //                   'Create',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //     },
          //     icon: const Icon(Icons.add, color: Colors.blue),
          //     label:
          //         const Text('New List', style: TextStyle(color: Colors.blue)),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.white,
          //       minimumSize: const Size(double.infinity, 40),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Consumer<UserListsNotifier>(
              builder: (context, userListsNotifier, child) {
                final userLists = userListsNotifier.userLists;
                return ListView.builder(
                  itemCount: userLists.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryInfoPage(
                                categoryTitle: userLists[index],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Text(
                                  userLists[index],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              top: -20,
                              bottom: 0,
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete'),
                                        content: Text(
                                          'Are you sure you want to delete ${userLists[index]}?',
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
                                                  .removeList(index);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.more_horiz),
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
