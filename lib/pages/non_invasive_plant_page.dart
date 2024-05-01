// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../functions/wiki_webscrape.dart';
import '../functions/get_configuration.dart';
import 'log_in_page.dart';
import 'saved_lists_page.dart';
import '../global/GlobalVariables.dart';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

class NonInvasivePlantPage extends StatefulWidget {
  final String? commonName, scientificName, imageUrl, accuracyScoreString;

  const NonInvasivePlantPage(
      {super.key,
      this.commonName,
      this.scientificName,
      this.imageUrl,
      this.accuracyScoreString});

  @override
  _NonInvasivePlantPageState createState() => _NonInvasivePlantPageState();
}

class _NonInvasivePlantPageState extends State<NonInvasivePlantPage>
    with AutomaticKeepAliveClientMixin<NonInvasivePlantPage> {
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
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor),
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
                    builder: (context) => const SavedListsPage(),
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
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
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
                        style: const TextStyle(
                            fontSize: 20, color: AppColors.primaryColor),
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
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primaryColor,
                            )
                          : null,
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
        final scientificName = widget.scientificName!;
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
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.secondaryColor),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CameraPage(),
                ),
              );
            },
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_box,
                color: AppColors.secondaryColor,
              ),
              Text(
                ' Safe Plant ',
                style: TextStyle(
                    color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.check_box,
                color: AppColors.secondaryColor,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.playlist_add,
                color: AppColors.primaryColor,
                size: 35,
              ),
              onPressed: () async {
                if (!isSignedIn) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        'Please log in to save plants',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor),
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
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: const EdgeInsets.fromLTRB(115, 5, 115, 10),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Accuracy: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.accuracyScoreString!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Text(
                widget.commonName!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                widget.scientificName!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, Object>>(
                future: webscrapeWikipedia(widget.scientificName!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Gathering info...',
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 40,
                        ),
                      ],
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No Wikipedia info available'));
                  } else {
                    Map<String, Object> wikiInfo = snapshot.data!;
                    // Display Wikipedia info
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Introduction',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 246, 0),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            wikiInfo['overview'].toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          // Display body if available
                          if (wikiInfo['body'] != null &&
                              wikiInfo['body'] is List &&
                              (wikiInfo['body'] as List).isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  'Overview',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 274, 0),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...List.generate(
                                  (wikiInfo['body'] as List).length,
                                  (index) {
                                    final body = wikiInfo['body'] as List?;
                                    if (body != null && index < body.length) {
                                      final header =
                                          body[index]?['header'] ?? '';
                                      final bodyContent =
                                          body[index]?['body'] ?? '';

                                      // Check if both header and body content are not empty
                                      if (header.isNotEmpty &&
                                          bodyContent.isNotEmpty) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$header:',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              bodyContent,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                    }
                                    return const SizedBox(); // A placeholder or an empty widget
                                  },
                                ),
                              ],
                            ),
                          // Display speciesImages if available
                          if (wikiInfo['speciesImages'] != null &&
                              (wikiInfo['speciesImages'] as List).isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Images',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 294, 0),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        (wikiInfo['speciesImages'] as List)
                                            .length,
                                    itemBuilder: (context, index) {
                                      final speciesImages =
                                          wikiInfo['speciesImages'] as List?;
                                      if (speciesImages != null &&
                                          index < speciesImages.length) {
                                        final imageUrl =
                                            speciesImages[index] as String;
                                        final lowerCaseImageUrl =
                                            imageUrl.toLowerCase();
                                        if (lowerCaseImageUrl
                                                .endsWith('.jpg') ||
                                            lowerCaseImageUrl
                                                .endsWith('.jpeg') ||
                                            lowerCaseImageUrl
                                                .endsWith('.png')) {
                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => Dialog(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 5, 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Invalid image format, return an empty container
                                          return Container();
                                        }
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          // Display wikiUrl as a clickable link
                          if (wikiInfo['wikiUrl'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  'Source',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 296, 0),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () async {
                                    // Open Wikipedia link in the browser
                                    String url = wikiInfo['wikiUrl'].toString();
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      wikiInfo['wikiUrl']!.toString(),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
