// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'plant_info_from_category_invasive_page.dart';
import 'camera_page.dart';
import 'my_plants_page.dart';
import 'settings_page.dart';
import 'wiki_webscrape.dart';
import 'location_function.dart';
import 'lib.dart';
import 'package:flutter_app/log_in_page.dart';
import 'global_variables.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  ///
  /// OPERATIONAL Variables
  int? nextOffset; // Track the next offset of pagination
  String searchText = '';
  late DefaultCacheManager _apiCache;

  @override
  void initState() {
    super.initState();
    _apiCache = DefaultCacheManager();

    // Get all data from region
    getAllRegions().then((value) => {
          // Select region based on current location
          if(selectedRegion.keys.isEmpty){
            getRegionFromCurrentLocation().then((value) => {
                  if (selectedRegion.keys.isEmpty && regionList.isNotEmpty)
                    {
                      // Select first element in the array as selected region
                      selectedRegion = regionList[0]
                    }
                  else
                    {
                      ///
                      /// ERROR CASE
                      /// Need to find a wait to throw errors
                    }
                })
          }
        });

    // Get all species from server
    fetchDataIfNeeded();

    // Testing Functions
    // webscrapeWikipedia("nymphaea odorata");
    getCurrentProvince();
  }

  // Get region based on current location
  Future<void> getRegionFromCurrentLocation() async {
    // Get current locaiton
    Map<String, dynamic> currRegion = await getCurrentProvince();

    if (currRegion["isError"]) {
      throw currRegion["errorMsg"];
    }

    // Make API request
    var configuration = getConfiguration();
    String? apiKey = configuration["apiKey"];
    String? regionCodeName = currRegion["regionCode"];
    String country = currRegion["countryFullname"];

    if (apiKey != null &&
        apiKey.isNotEmpty &&
        regionCodeName != null &&
        regionCodeName.isNotEmpty) {
      String? baseUrl = configuration["apiBaseUrl"];
      String endpoint = 'region?region_code_name=$regionCodeName';
      String apiUrl = '$baseUrl$endpoint';

      Uri req = Uri.parse(apiUrl);
      final response = await http.get(req, headers: {'x-api-key': apiKey});

      var resDecode = jsonDecode(response.body);

      // Check if the country is correct
      for (int i = 0; i < resDecode["regions"].length; i++) {
        if (resDecode["regions"][i]["country_fullname"]
                .toString()
                .toLowerCase() ==
            country.toLowerCase()) {
          setState(() {
            selectedRegion = resDecode["regions"][i];
          });
          break;
        }
      }
    } else {
      throw ("Api key not found.");
    }
  }

  // Get call regions from server
  Future<void> getAllRegions() async {
    if(regionList.length > 0){
      return ;
    }
    // Make API request
    var configuration = getConfiguration();
    String? apiKey = configuration["apiKey"];

    if (apiKey != null && apiKey.isNotEmpty) {
      String? baseUrl = configuration["apiBaseUrl"];
      String endpoint = 'region';
      String apiUrl = '$baseUrl$endpoint';
      
      String stringResponseBody;
      bool isResponseWeb = false;


      // Try reading data from cache
      String modifiedUrl = apiUrl.replaceAll('&', 'a').replaceAll('=', 'e');
      FileInfo? file = await _apiCache.getFileFromCache(modifiedUrl);
      if (file != null && file.file.existsSync()) {
        stringResponseBody = await file.file.readAsString();
      } 
      // Cache missed, get result from the api
      else{
        final response = await http.get(Uri.parse(apiUrl), headers: {'x-api-key': apiKey});
        if (response.statusCode == 200) {
          stringResponseBody = response.body;
          isResponseWeb = true;
        } else{
          throw Exception('Failed to load data.');
        }
      }
      
      var resDecode = jsonDecode(stringResponseBody);

      setState(() {
        regionList = resDecode["regions"];
      });

      // Save only if response come from api
      if(isResponseWeb){
        Directory tempDir = await getTemporaryDirectory();
        String cachePath = '${tempDir.path}/cache_data.json';
        File file = File(cachePath);
        await file.writeAsString(stringResponseBody);

        await _apiCache.putFile(modifiedUrl, file.readAsBytesSync(), maxAge: Duration(days: maxCacheDay));
      }
    } else {
      throw ("Api key not found.");
    }
  }

  Future<void> fetchDataIfNeeded() async {
    bool isMoreData = await fetchData(); // Fetch the initial page without last_species_id

    // Fetch subsequent pages
    while (isMoreData) {
      isMoreData = await fetchData();
    }
  }

  // Return true if more data is expected, else false
  Future<bool> fetchData() async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    const endpoint = 'invasiveSpecies?rows_per_page=$pageSize';
    bool returnValue = true;

    // Modify URL to include last_species_id if available
    String apiUrl = '$baseUrl$endpoint';
    if (nextOffset != null) {
      apiUrl += '&curr_offset=$nextOffset';
    }

    String? apiKey = configuration["apiKey"];
    if (apiKey != null && apiKey.isNotEmpty) {
      var stringResponseBody;
      bool isResponseWeb = false;

      // Try read data from cache first
      String modifiedUrl = apiUrl.replaceAll('&', 'a').replaceAll('=', 'e');
      FileInfo? file = await _apiCache.getFileFromCache(modifiedUrl);
      if (file != null && file.file.existsSync()) {
        stringResponseBody = await file.file.readAsString();
      } 
      // Cache missed, get result from the api
      else{
        final response = await http.get(Uri.parse(apiUrl), headers: {'x-api-key': apiKey});
        if (response.statusCode == 200) {
          stringResponseBody = response.body;
          isResponseWeb = true;
        } else{
          throw Exception('Failed to load data.');
        }
      }

      final jsonResponse = json.decode(stringResponseBody);

      // Check if incoming nextOffset is same as current nextOffset
      if (jsonResponse["nextOffset"] == nextOffset ||
          jsonResponse["species"].length < pageSize) {
        returnValue = false;
      }

      setState(() {
        if (nextOffset != null) {
          // Append fetched data to existing speciesData
          speciesData.addAll(jsonResponse["species"] as List<dynamic>);
        } else {
          speciesData = jsonResponse["species"] as List<dynamic>;
        }

        // Get offset of next page, provided by esponse
        nextOffset = jsonResponse["nextOffset"];
      });

      // Save only if response come from api
      if(isResponseWeb){
        Directory tempDir = await getTemporaryDirectory();
        String cachePath = '${tempDir.path}/cache_data.json';
        File file = File(cachePath);
        await file.writeAsString(stringResponseBody);

        await _apiCache.putFile(modifiedUrl, file.readAsBytesSync(), maxAge: Duration(days: maxCacheDay));
      }

      return returnValue;
    } else {
      throw Exception('Invalid API key.');
    }
  }

  List<dynamic> getSpeciesByRegion(String regionId) {
    return speciesData
        .where((species) => species['region_id'].contains(regionId))
        .toList();
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

  String formatRegionName(String regionName) {
    String? formattedName =
        regionName.replaceAll('_', ' '); // Replace underscore with space
    formattedName = formattedName.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    return formattedName;
  }

  Future<void> _showUserProfile() async {
    bool isSignedIn = await isUserSignedIn();

    if (isSignedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Actions:',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    await signOutCurrentUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 2000),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        content: const Text('Signed out'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const LogInPage()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    bool deleteConfirmed =
                        await showConfirmationDialog(context);
                    if (deleteConfirmed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 2000),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: const Text('User Deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const LogInPage()),
                      );
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delete User',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LogInPage()),
      );
    }
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'This will delete your user permanently. You cannot undo this action.',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                await deleteUser();
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes, Delete it',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    return deleteConfirmed ?? false; // Return false if deleteConfirmed is null
  }

  Future<bool> isUserSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } catch (e) {
      print('Error checking auth session: $e');
      return false;
    }
  }

  Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  Future<void> deleteUser() async {
    try {
      await Amplify.Auth.deleteUser();
      print('user deleted');
      safePrint('Delete user succeeded');
    } on AuthException catch (e) {
      safePrint('Delete user failed with error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: GestureDetector(
              onTap: () {
                _showUserProfile();
              },
              child: Image.asset(
                'assets/images/profile.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          title: const Text(
            "Invasive Species",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
                const SizedBox(width: 5),
                DropdownButtonHideUnderline(
                  child: selectedRegion["region_fullname"] != null
                      ? DropdownButton<String>(
                          value: formatRegionName(
                              selectedRegion["region_fullname"]!),
                          items: regionList.map((dynamic value) {
                            return DropdownMenuItem<String>(
                              value:
                                  formatRegionName(value["region_fullname"]!),
                              child: Text(
                                  formatRegionName(value["region_fullname"]!)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(
                              () {
                                // Update currently selected
                                if (newValue != null && newValue.isNotEmpty) {
                                  for (int i = 0; i < regionList.length; i++) {
                                    if (formatRegionName(regionList[i]
                                            ["region_fullname"]!) ==
                                        newValue) {
                                      selectedRegion = regionList[i];
                                      break;
                                    }
                                  }
                                }
                              },
                            );
                          },
                        )
                      : const Text('No region selected'),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: _buildMatchingItems(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
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
                  icon: Icon(Icons.home_rounded, size: 40),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined, size: 40),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark, size: 40),
                  label: '',
                ),
              ],
              onTap: (int index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraPage(),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyPlantsPage(),
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

  Widget _buildGridItem(Map<String, dynamic> species) {
    String speciesName = species['scientific_name'][0];
    String formattedName = formatSpeciesName(speciesName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantInfoFromCategoryInvasivePage(
              speciesObject: species, // Pass the entire species object
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            formattedName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMatchingItems() {
    List<Widget> matchingItems = [];

    List<dynamic> filteredSpecies = [];
    if (speciesData.isNotEmpty) {
      final regionId = selectedRegion["region_id"].toString();
      if (regionId != Null) {
        filteredSpecies = getSpeciesByRegion(regionId);
      }
    }

    for (int index = 0; index < filteredSpecies.length; index++) {
      final species = filteredSpecies[index];

      String speciesName = species['scientific_name'][0];
      String formattedName = formatSpeciesName(speciesName);

      // Check if the search text matches the formatted name
      if (formattedName.toLowerCase().contains(searchText.toLowerCase())) {
        matchingItems.add(_buildGridItem(species));
      }
    }

    return matchingItems;
  }
}
