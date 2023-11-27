// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'plant_info_from_category_invasive_page.dart';
import 'camera_page.dart';
import 'my_plants_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLocation = 'British Columbia';
  bool isBCSelected = true;
  String searchText = '';
  late List<dynamic> speciesData = [];

  final String regionIDBC = '7ae91c1e-3444-42b9-83a9-c0d9e25d1981';
  final String regionIDON = '82c70f8d-e00a-47af-a312-e5dda299e1af';
  DateTime? lastFetchTime; // Track the last fetch time

  late DefaultCacheManager _cacheManager;

  @override
  void initState() {
    super.initState();
    _cacheManager = DefaultCacheManager();
    fetchDataIfNeeded();
    lastFetchTime = DateTime.now();
  }

  Future<void> fetchDataIfNeeded() async {
    const baseUrl =
        'https://jfz3gup42l.execute-api.ca-central-1.amazonaws.com/prod';
    const endpoint = '/invasiveSpecies';
    const cacheKey = '$baseUrl$endpoint';

    FileInfo? fileInfo = await _cacheManager.getFileFromCache(cacheKey);

    if (fileInfo == null ||
        DateTime.now().difference(lastFetchTime!) >
            const Duration(minutes: 5)) {
      await fetchData(cacheKey);
      lastFetchTime = DateTime.now();
    } else {
      String response = await fileInfo.file.readAsString();
      final jsonResponse = json.decode(response);
      setState(() {
        speciesData = jsonResponse as List<dynamic>;
      });
      debugPrint('Cached file path: ${fileInfo.file.path}');
    }
  }

  Future<void> fetchData(String cacheKey) async {
    const baseUrl =
        'https://jfz3gup42l.execute-api.ca-central-1.amazonaws.com/prod';
    const endpoint = '/invasiveSpecies';

    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        speciesData = jsonResponse as List<dynamic>;
      });

      Directory tempDir = await getTemporaryDirectory();
      String cachePath = '${tempDir.path}/cache_data.json';
      File file = File(cachePath);
      await file.writeAsString(response.body);

      _cacheManager.putFile(cacheKey, file.readAsBytesSync());
    } else {
      throw Exception('Failed to load data');
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
    return Scaffold(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(
                    profileImagePath: 'assets/images/profile.png',
                  ),
                ),
              );
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
                child: DropdownButton<String>(
                  value: selectedLocation,
                  items: <String>['British Columbia', 'Ontario']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(
                      () {
                        selectedLocation = newValue ?? selectedLocation;
                        isBCSelected = newValue == 'British Columbia';
                      },
                    );
                  },
                ),
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

// In _buildMatchingItems function
  List<Widget> _buildMatchingItems() {
    List<Widget> matchingItems = [];

    List<dynamic> filteredSpecies = [];
    if (speciesData.isNotEmpty) {
      final regionId = isBCSelected ? regionIDBC : regionIDON;
      filteredSpecies = getSpeciesByRegion(regionId);
    }

    for (int index = 0; index < filteredSpecies.length; index++) {
      final species = filteredSpecies[index];

      // Pass the entire species object to _buildGridItem
      matchingItems.add(_buildGridItem(species));
    }

    return matchingItems;
  }
}
