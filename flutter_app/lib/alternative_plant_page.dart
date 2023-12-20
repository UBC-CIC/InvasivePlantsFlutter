// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/GetConfigs.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:flutter_app/saved_lists_page.dart';
import 'GlobalVariables.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

class PlantInfoFromCategoryPage extends StatefulWidget {
  final Map<String, dynamic> speciesObject;
  const PlantInfoFromCategoryPage({
    super.key,
    required this.speciesObject,
  });

  @override
  _PlantInfoFromCategoryPageState createState() =>
      _PlantInfoFromCategoryPageState();
}

class _PlantInfoFromCategoryPageState extends State<PlantInfoFromCategoryPage>
    with AutomaticKeepAliveClientMixin<PlantInfoFromCategoryPage> {
  @override
  bool get wantKeepAlive => true;
  bool isSignedIn = false;
  Set<String> selectedListItems = <String>{};
  List<Map<String, dynamic>> listData = [];

  @override
  void initState() {
    super.initState();
    checkUserSignIn();
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

  Future<List<Map<String, dynamic>>> fetchListData() async {
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
        final List<dynamic> data = json.decode(response.body);
        listData = List<Map<String, dynamic>>.from(data);
        return listData;
      } else {
        throw Exception('Failed to load list data');
      }
    } catch (e) {
      print('Error fetching saved lists: $e');
      return [];
    }
  }

  void showListDropdown(List<Map<String, dynamic>> listData) {
    if (listData.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            'Please create a list first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPlantsPage(),
                  ),
                );
              },
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Select a list:',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: listData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String listName = listData[index]['list_name'];
                    final bool isSelected =
                        selectedListItems.contains(listName);

                    return ListTile(
                      title: Text(
                        listName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        setState(
                          () {
                            if (isSelected) {
                              selectedListItems.remove(listName);
                            } else {
                              selectedListItems.add(listName);
                            }
                          },
                        );
                      },
                      trailing: isSelected ? const Icon(Icons.check) : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    savePlantsToSelectedLists();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  Future<void> savePlantToSelectedLists(
      String listId, String listName, String scientificName) async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList/$listId';
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
        final List<dynamic> data = json.decode(response.body);
        final existingSpecies = data
            .map((item) => item['saved_species'])
            .expand((i) => i)
            .toList()
            .cast<String>();

        // Add the scientificName if it doesn't exist in the existing saved_species
        if (!existingSpecies.contains(scientificName)) {
          final updatedSpecies = [...existingSpecies, scientificName];
          final body = jsonEncode({
            'list_name': listName,
            'saved_species': updatedSpecies,
          });

          final putResponse = await http.put(
            req,
            headers: {
              'Authorization': accessToken,
            },
            body: body,
          );

          if (putResponse.statusCode != 200) {
            throw Exception('Failed to save plant');
          }
          print(putResponse.body);
        }
      } else {
        throw Exception('Failed to load list data');
      }
    } catch (e) {
      print('Error saving plant: $e');
    }
  }

  Future<void> savePlantsToSelectedLists() async {
    List<String> selectedItems = selectedListItems.toList();
    for (String selectedItem in selectedItems) {
      final selectedItemData = listData.firstWhere(
        (element) => element['list_name'] == selectedItem,
        orElse: () => <String, dynamic>{},
      );
      if (selectedItemData.isNotEmpty) {
        final listId = selectedItemData['list_id'];
        final scientificName = widget.speciesObject['scientific_name'][0];
        await savePlantToSelectedLists(listId, selectedItem, scientificName);
      }
    }
    refreshedLists = 0;
    displaySnackBar();
  }

  void displaySnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: const Text("Plant saved!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String formatSpeciesName(String speciesName) {
    String formattedName =
        speciesName.replaceAll('_', ' '); // Replace underscore with space
    formattedName = formattedName.trim(); // Remove leading/trailing whitespace

    List<String> words = formattedName.split(' '); // Split into words
    if (words.isNotEmpty) {
      // Capitalize the first word and make the rest lowercase
      String firstWord = words[0].substring(0, 1).toUpperCase() +
          words[0].substring(1).toLowerCase();
      // Join the first capitalized word with the rest of the words
      formattedName = '$firstWord ${words.sublist(1).join(' ').toLowerCase()}';
    }
    return formattedName;
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.speciesObject['images'].isEmpty
        ? 'assets/images/noImageAvailable.png'
        : (widget.speciesObject['images'][0]['image_url'].isEmpty
            ? 'assets/images/noImageAvailable.png'
            : widget.speciesObject['images'][0]['image_url']);
    String commonName = widget.speciesObject['common_name'].isNotEmpty
        ? widget.speciesObject['common_name'][0]
        : widget.speciesObject['scientific_name'][0];
    String scientificName = widget.speciesObject['scientific_name'][0];
    // Ensure UTF-8 decoding for the species description to remove special characters
    String speciesDescription = utf8.decode(
      widget.speciesObject['species_description'].codeUnits,
    );
    List<String> resourceLinks =
        List<String>.from(widget.speciesObject['resource_links'] ?? []);

    super.build(context);
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Plant Info',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.playlist_add,
                color: Colors.lightBlue,
                size: 35,
              ),
              onPressed: () async {
                if (!isSignedIn) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        'Please log in to save plants',
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogInPage()),
                            );
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  try {
                    List<Map<String, dynamic>> listData = await fetchListData();
                    showListDropdown(listData);
                  } catch (e) {
                    print('Error fetching list data: $e');
                  }
                }
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: imageUrl.startsWith('https')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageUrl.startsWith('https')
                        ? NetworkImage(imageUrl)
                        : AssetImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height / 2.5,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Text(
                utf8.decode(formatSpeciesName(commonName).codeUnits),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                utf8.decode(formatSpeciesName(scientificName).codeUnits),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Text(
                        speciesDescription,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    if (resourceLinks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Source:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 5),
                            // Generate list of clickable URLs
                            ...resourceLinks.map(
                              (link) => GestureDetector(
                                onTap: () async {
                                  if (await canLaunch(link)) {
                                    await launch(link);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },
                                child: Text(
                                  link,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
