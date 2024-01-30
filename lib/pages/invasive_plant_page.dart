// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Import dart:convert to use utf8 decoding
import '../functions/get_configuration.dart';
import 'log_in_page.dart';
import 'saved_lists_page.dart';
import '../global/GlobalVariables.dart';

import 'alternative_plant_page.dart';
import '../functions/wiki_webscrape.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

class InvasivePlantPage extends StatefulWidget {
  final Map<String, dynamic> speciesObject;
  final String? commonName, regionId, plantNetImageURL, accuracyScoreString;

  const InvasivePlantPage(
      {super.key,
      required this.speciesObject,
      this.commonName,
      this.regionId,
      this.plantNetImageURL,
      this.accuracyScoreString});

  @override
  _InvasivePlantPageState createState() => _InvasivePlantPageState();
}

class _InvasivePlantPageState extends State<InvasivePlantPage>
    with AutomaticKeepAliveClientMixin<InvasivePlantPage> {
  @override
  bool get wantKeepAlive => true;
  late Map<String, Object> wikiInfo;
  String firstImageURL = '';
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
              color: AppColors.primaryColor,
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
                  color: AppColors.primaryColor,
                ),
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
                          fontSize: 20,
                          color: AppColors.primaryColor,
                        ),
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
        backgroundColor: AppColors.primaryColor,
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
    super.build(context);
    String scientificName = widget.speciesObject['scientific_name'][0];
    // Ensure UTF-8 decoding for the species description to remove special characters
    String speciesDescription = utf8.decode(
      widget.speciesObject['species_description'].codeUnits,
    ); // Fetch data when the page initializes

    List<String> resourceLinks =
        List<String>.from(widget.speciesObject['resource_links'] ?? []);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: AppColors.secondaryColor,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (widget.regionId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CameraPage(),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: AppColors.secondaryColor,
              ),
              Text(
                ' Invasive Plant ',
                style: TextStyle(
                    color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.warning,
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
                          color: AppColors.primaryColor,
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
                if (widget.plantNetImageURL != null || firstImageURL != '') {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: widget.plantNetImageURL != null
                            ? Image.network(
                                widget.plantNetImageURL!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                firstImageURL,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  widget.plantNetImageURL != null
                      ? Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(widget.plantNetImageURL!),
                                fit: BoxFit.cover,
                              )),
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: double.infinity,
                        )
                      : FutureBuilder<Map<String, Object>>(
                          future: webscrapeWikipedia(scientificName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  width: double.infinity,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Retrieving image...',
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  width: double.infinity,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No image is available',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  width: double.infinity,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No image is available',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              Map<String, Object> wikiInfo = snapshot.data!;
                              if (wikiInfo['speciesImages'] != null &&
                                  (wikiInfo['speciesImages'] as List)
                                      .isNotEmpty) {
                                final speciesImages =
                                    wikiInfo['speciesImages'] as List?;
                                if (speciesImages != null &&
                                    speciesImages.isNotEmpty) {
                                  final firstImageURL =
                                      speciesImages[0] as String;
                                  final lowerCaseImageUrl =
                                      firstImageURL.toLowerCase();
                                  if (lowerCaseImageUrl.endsWith('.jpg') ||
                                      lowerCaseImageUrl.endsWith('.jpeg') ||
                                      lowerCaseImageUrl.endsWith('.png')) {
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(firstImageURL),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      width: double.infinity,
                                    );
                                  }
                                }
                              }
                              return Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  width: double.infinity,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No image is available',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                  Visibility(
                    visible: widget.accuracyScoreString != null,
                    child: Positioned(
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
                                widget.accuracyScoreString ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: TabBar(
                        indicatorColor: AppColors.primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: AppColors.primaryColor,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelStyle:
                            TextStyle(fontWeight: FontWeight.normal),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(
                            text: 'About',
                          ),
                          Tab(
                            text: 'Wikipedia',
                          ),
                          Tab(
                            text: 'Alternatives',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Text(
                                    widget.commonName == null
                                        ? formatSpeciesName(scientificName)
                                        : widget.commonName!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.commonName != null,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(
                                      formatSpeciesName(scientificName),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.regionId != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Region: ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          '${widget.regionId}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 0),
                                  child: Text(
                                    speciesDescription,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                if (resourceLinks.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Source(s):',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
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
                                                  decoration:
                                                      TextDecoration.underline),
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
                          FutureBuilder<Map<String, Object>>(
                            future: webscrapeWikipedia(scientificName),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No Wikipedia info available'));
                              } else {
                                Map<String, Object> wikiInfo = snapshot.data!;
                                // Display Wikipedia info
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Introduction',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 246, 0),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Overview',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 274, 0),
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
                                                final body =
                                                    wikiInfo['body'] as List?;
                                                if (body != null &&
                                                    index < body.length) {
                                                  final header = body[index]
                                                          ?['header'] ??
                                                      '';
                                                  final bodyContent =
                                                      body[index]?['body'] ??
                                                          '';

                                                  // Check if both header and body content are not empty
                                                  if (header.isNotEmpty &&
                                                      bodyContent.isNotEmpty) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '$header:',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          bodyContent,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
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
                                          (wikiInfo['speciesImages'] as List)
                                              .isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Images',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 294, 0),
                                              child: Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    (wikiInfo['speciesImages']
                                                            as List)
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  final speciesImages =
                                                      wikiInfo['speciesImages']
                                                          as List?;
                                                  if (speciesImages != null &&
                                                      index <
                                                          speciesImages
                                                              .length) {
                                                    final imageUrl =
                                                        speciesImages[index]
                                                            as String;
                                                    final lowerCaseImageUrl =
                                                        imageUrl.toLowerCase();
                                                    if (lowerCaseImageUrl
                                                            .endsWith('.jpg') ||
                                                        lowerCaseImageUrl
                                                            .endsWith(
                                                                '.jpeg') ||
                                                        lowerCaseImageUrl
                                                            .endsWith('.png')) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                Dialog(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Image
                                                                    .network(
                                                                  imageUrl,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 10, 5, 5),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Source',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 296, 0),
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
                                                String url = wikiInfo['wikiUrl']
                                                    .toString();
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              child: Center(
                                                child: Text(
                                                  wikiInfo['wikiUrl']!
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
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
                          Column(
                            children: [
                              if (widget
                                  .speciesObject['alternative_species'].isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(50, 90, 50, 0),
                                    child: Text(
                                      'Sorry, there are no alternative species for this plant.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: widget
                                        .speciesObject['alternative_species']
                                        .length,
                                    itemBuilder: (context, index) {
                                      final alternativeSpecies =
                                          widget.speciesObject[
                                              'alternative_species'][index];

                                      String commonName = alternativeSpecies[
                                                  'common_name']
                                              .isNotEmpty
                                          ? alternativeSpecies['common_name'][0]
                                          : alternativeSpecies[
                                              'scientific_name'][0];

                                      String imageUrl =
                                          alternativeSpecies['images'].isEmpty
                                              ? 'assets/images/grey.jpeg'
                                              : (alternativeSpecies['images'][0]
                                                          ['image_url']
                                                      .isEmpty
                                                  ? 'assets/images/grey.jpeg'
                                                  : alternativeSpecies['images']
                                                      [0]['image_url']);

                                      return GestureDetector(
                                        onTap: () {
                                          final selectedSpecies =
                                              widget.speciesObject[
                                                  'alternative_species'][index];
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AlternativePlantPage(
                                                speciesObject: selectedSpecies,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 236, 236, 236),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                offset: const Offset(0, 6),
                                                blurRadius: 6,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageUrl
                                                            .startsWith('https')
                                                        ? NetworkImage(imageUrl)
                                                        : AssetImage(imageUrl)
                                                            as ImageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      utf8.decode(
                                                          formatSpeciesName(
                                                                  commonName)
                                                              .codeUnits),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(1, 0, 0, 0),
                                                      child: Text(
                                                        utf8.decode(formatSpeciesName(
                                                                alternativeSpecies[
                                                                    'scientific_name'][0])
                                                            .codeUnits),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
