// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/plant_info_from_category_page.dart';
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
        title: Row(
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
                items:
                    <String>['British Columbia', 'Ontario'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLocation = newValue ?? selectedLocation;
                    isBCSelected = newValue == 'British Columbia';
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: CupertinoSearchTextField(
              placeholder: 'Search',
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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

  List<Widget> _buildMatchingItems() {
    List<Widget> matchingItems = [];

    for (int index = 0; index < 12; index++) {
      final speciesName =
          '${isBCSelected ? 'BC' : 'ONTARIO'} SPECIES ${index + 1}';
      if (searchText.isEmpty ||
          speciesName.toLowerCase().contains(searchText.toLowerCase())) {
        matchingItems.add(_buildGridItem(speciesName));
      }
    }

    return matchingItems;
  }

  Widget _buildGridItem(String speciesName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantInfoFromCategoryPage(
              plantName: speciesName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isBCSelected
                ? <Color>[
                    const Color.fromARGB(255, 0, 140, 255),
                    const Color.fromARGB(255, 139, 203, 255),
                  ]
                : <Color>[
                    Colors.green,
                    const Color.fromARGB(255, 155, 218, 157),
                  ],
          ),
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
            speciesName,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
