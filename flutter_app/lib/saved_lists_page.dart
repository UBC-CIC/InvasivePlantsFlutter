// ignore_for_file: avoid_print, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/plant_list_page.dart';
import 'package:flutter_app/log_in_page.dart';
import 'camera_page.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'plant_list_notifier.dart';
import 'get_configuration.dart';
import 'GlobalVariables.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListsNotifier extends ChangeNotifier {
  Map<String, PlantListNotifier> userLists = {};

  Future<void> addNewList(String listName) async {
    final newListName = listName; // Create a unique ID for the list
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final body = jsonEncode({'list_name': newListName, 'saved_species': []});
      final response = await http.post(
        req,
        headers: {
          'Authorization': accessToken,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var resDecode = jsonDecode(response.body);
        print('Result: $resDecode');

        if (resDecode.containsKey('list_id')) {
          var listIdValue = resDecode['list_id'];
          print('List ID: $listIdValue');

          // Update the PlantListNotifier with list name and list_id
          PlantListNotifier newList = PlantListNotifier();
          newList.setItemCount(0); // Set default item count
          newList.listName = newListName; // Assign list name
          newList.listId = listIdValue; // Assign list_id from response

          userLists[newListName] =
              newList; // Update userLists with new PlantListNotifier
          notifyListeners();
        } else {
          print('list_id not found in the response');
        }
      } else {
        print('Failed to send API request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending API request: $e');
    }
  }

  Future<String> _extractAccessToken() async {
    final rawResult = await Amplify.Auth.fetchAuthSession();
    final result = jsonDecode(rawResult.toString());
    final userPoolTokens = result['userPoolTokens'];

    try {
      final accessToken = extractAccessToken(userPoolTokens);
      return accessToken;
    } catch (e) {
      print('Error extracting access token: $e');
    }
    return "";
  }

  String extractAccessToken(String inputString) {
    final accessTokenStart =
        inputString.indexOf('"accessToken": "') + '"accessToken": "'.length;
    final accessTokenEnd = inputString.indexOf('"', accessTokenStart);
    return inputString.substring(accessTokenStart, accessTokenEnd);
  }

  Future<void> removeList(String listId, String listName) async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList/$listId';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final response = await http.delete(
        req,
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        // Successful deletion, update local data
        if (userLists.containsKey(listId)) {
          userLists.remove(listId); // Remove locally created list
        } else {
          // Remove fetched list if exists
          String? fetchedListId;
          userLists.forEach(
            (key, value) {
              if (value.listName == listName) {
                fetchedListId = key;
              }
            },
          );
          if (fetchedListId != null) {
            userLists.remove(fetchedListId);
          }
        }
        notifyListeners(); // Notify listeners after deleting
      } else {
        print('Failed to delete list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending DELETE request: $e');
    }
  }

  PlantListNotifier getOrCreateList(String listId) {
    return userLists.putIfAbsent(listId, () => PlantListNotifier());
  }
}

class PlantDetailsNotifier extends ChangeNotifier {
  late int _itemCount = 0;
  int get itemCount => _itemCount;

  void setItemCount(int newItemCount) {
    _itemCount = newItemCount;
    notifyListeners();
  }
}

class SavedListsPage extends StatefulWidget {
  const SavedListsPage({super.key});

  @override
  State<SavedListsPage> createState() => _SavedListsPageState();
}

class _SavedListsPageState extends State<SavedListsPage> {
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    checkUserSignIn();
    if (refreshedLists == 0) {
      print('fetched lists');
      fetchSavedLists();
      refreshedLists = 1;
    }
  }

  Future<String> _extractAccessToken() async {
    final rawResult = await Amplify.Auth.fetchAuthSession();
    final result = jsonDecode(rawResult.toString());
    final userPoolTokens = result['userPoolTokens'];

    try {
      final accessToken = extractAccessToken(userPoolTokens);
      return accessToken;
    } catch (e) {
      print('Error extracting access token: $e');
    }
    return "";
  }

  String extractAccessToken(String inputString) {
    final accessTokenStart =
        inputString.indexOf('"accessToken": "') + '"accessToken": "'.length;
    final accessTokenEnd = inputString.indexOf('"', accessTokenStart);
    return inputString.substring(accessTokenStart, accessTokenEnd);
  }

  Future<void> fetchSavedLists() async {
    final userListsNotifier =
        Provider.of<UserListsNotifier>(context, listen: false);
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final response = await http.get(
        req,
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        userListsNotifier.userLists.clear();

        final List<dynamic> lists = jsonDecode(response.body);

        // Process the fetched lists and update PlantListNotifier
        for (var listData in lists) {
          final listId = listData['list_id'];
          final listName = listData['list_name'];
          final savedSpecies = listData['saved_species'];

          // Create or update PlantListNotifier instances with fetched data
          final plantListNotifier = PlantListNotifier();
          plantListNotifier.listId = listId;
          plantListNotifier.listName = listName;
          plantListNotifier.setItemCount(savedSpecies.length);

          userListsNotifier.userLists[listId] = plantListNotifier;
        }

        // Notify listeners after updating the lists
        userListsNotifier.notifyListeners();
      } else {
        print('Failed to fetch saved lists: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching saved lists: $e');
    }
  }

  Future<void> checkUserSignIn() async {
    bool signedIn = await isUserSignedIn();
    setState(() {
      isSignedIn = signedIn; // Update the sign-in status
    });
  }

  Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'MY LISTS',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'To create lists of plants,\n',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 23,
                          ),
                        ),
                        const TextSpan(
                          text: 'please ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 23,
                          ),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogInPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(37)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10),
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
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'MY LISTS',
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
                                      content:
                                          const Text('Please enter a name'),
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
                  icon: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 35,
                  ),
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
                  if (userLists.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Click ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 23,
                                  ),
                                ),
                                TextSpan(
                                  text: '+',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 25,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String newListName = '';
                                          return AlertDialog(
                                            title: const Text(
                                                'Enter Your List Name:'),
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
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (newListName
                                                      .trim()
                                                      .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1000),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        content: const Text(
                                                            'Please enter a name'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  } else {
                                                    final userListsNotifier =
                                                        Provider.of<
                                                                UserListsNotifier>(
                                                            context,
                                                            listen: false);
                                                    userListsNotifier
                                                        .addNewList(
                                                            newListName);
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                                child: const Text(
                                                  'Create',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                ),
                                const TextSpan(
                                  text: ' to create a list of plants',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 23,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 110),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: userLists.length,
                    itemBuilder: (context, index) {
                      final listId = userLists[index];
                      final plantListNotifier =
                          userListsNotifier.getOrCreateList(listId);

                      // Fetch individual values for each list
                      int itemCount = plantListNotifier.itemCount;

                      return Container(
                        margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 223, 250, 224),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: kElevationToShadow[3],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (itemCount == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1000),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  content: const Text(
                                      'Add some plants to this list'),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            } else {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                    create: (context) => plantListNotifier,
                                    child: PlantListPage(
                                      listId: plantListNotifier.listId,
                                      categoryTitle: plantListNotifier.listName,
                                    ),
                                  ),
                                ),
                              );
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                plantListNotifier
                                    .setItemCount(result['itemCount']);
                                setState(() {});
                              }
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RawMaterialButton(
                                onPressed: () async {
                                  if (itemCount == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        content: const Text(
                                            'Add some plants to this list'),
                                        backgroundColor: Colors.grey,
                                      ),
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeNotifierProvider(
                                          create: (context) =>
                                              plantListNotifier,
                                          child: PlantListPage(
                                            listId: plantListNotifier.listId,
                                            categoryTitle:
                                                plantListNotifier.listName,
                                          ),
                                        ),
                                      ),
                                    );
                                    if (result != null &&
                                        result is Map<String, dynamic>) {
                                      plantListNotifier
                                          .setItemCount(result['itemCount']);
                                      setState(() {});
                                    }
                                  }
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                fillColor:
                                    const Color.fromARGB(255, 148, 201, 130),
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                shape: const CircleBorder(),
                                elevation: 0,
                                child: const Icon(
                                  Icons.folder,
                                  size: 25.0,
                                  color: Color.fromARGB(255, 190, 255, 192),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plantListNotifier.listName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          'Number of plants: ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        Text(
                                          '$itemCount',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete List'),
                                          content: Text(
                                            'Are you sure you want to delete ${plantListNotifier.listName}?',
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
                                                userListsNotifier.removeList(
                                                    plantListNotifier.listId,
                                                    plantListNotifier.listName);
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
      ),
    );
  }
}
