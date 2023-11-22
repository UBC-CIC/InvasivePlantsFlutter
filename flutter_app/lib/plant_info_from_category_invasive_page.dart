// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_app/plant_info_from_category_page.dart';

class PlantInfoFromCategoryInvasivePage extends StatefulWidget {
  final String plantName;
  final String speciesId;

  const PlantInfoFromCategoryInvasivePage(
      {super.key, required this.plantName, required this.speciesId});

  @override
  _PlantInfoFromCategoryInvasivePageState createState() =>
      _PlantInfoFromCategoryInvasivePageState();
}

class _PlantInfoFromCategoryInvasivePageState
    extends State<PlantInfoFromCategoryInvasivePage>
    with AutomaticKeepAliveClientMixin<PlantInfoFromCategoryInvasivePage> {
  @override
  bool get wantKeepAlive => true;
  bool isBookmarked = false;

  void _showImageFullScreenDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  String formatSpeciesName(String speciesName) {
    String formattedName =
        speciesName.replaceAll('_', ' '); // Replace underscore with space
    List<String> words = formattedName.split(' '); // Split into words
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase();
      }
      return ''; // Return an empty string if the word is empty
    }).toList(); // Capitalize each word
    return capitalizedWords.join(' '); // Join words with space (no newlines)
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            Text(
              ' Invasive Plant ',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: isBookmarked
                ? const Icon(
                    Icons.bookmark,
                    color: Colors.lightBlue,
                  )
                : const Icon(Icons.bookmark_border),
            onPressed: () {
              setState(
                () {
                  isBookmarked = !isBookmarked;
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showImageFullScreenDialog(
                      'assets/images/scotchbroom1.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 2.5, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/scotchbroom1.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showImageFullScreenDialog(
                      'assets/images/scotchbroom2.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(2.5, 0, 10, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/scotchbroom2.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _showImageFullScreenDialog(
                'assets/images/scotchbroom3.jpeg',
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/scotchbroom3.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TabBar(
                      indicatorColor: Color.fromARGB(255, 76, 175, 130),
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.black,
                      labelColor: Colors.black,
                      unselectedLabelStyle:
                          TextStyle(fontWeight: FontWeight.normal),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          text: 'About',
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
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  formatSpeciesName(
                                      widget.plantName), // Handle null case
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  'Scotch Broom',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 30),
                                child: Text(
                                  'Scotch broom is a perennial evergreen shrub in the legume family. \n\nIt grows up to 10 feet tall. It has stiff, dark green branches, which grow more or less erect, and often have few leaves. The lower leaves have three lobes, while the upper leaves are simple. \n\nScotch broom has bright yellow flowers, which are shaped like pea flowers and are about ¾ inch long. The plants bloom from April to June, forming green seedpods, which turn black or brown as they mature. \n\nThe pods each contain several seeds. There are several other introduced brooms, which are similar to Scotch broom and may also be invasive.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context)
                                  .size
                                  .height - // Set height relative to the available height
                              kToolbarHeight - // subtract the app bar height
                              200, // subtract any other fixed heights
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  final plantIndex = 'Plant ${index + 1}';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlantInfoFromCategoryPage(
                                        plantName: plantIndex,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 236, 236, 236)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
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
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/swordfern2.jpeg'),
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
                                              const SizedBox(height: 10),
                                              Text(
                                                'Plant ${index + 1}',
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Scientific Name',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 43, 75, 90)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              );
                            },
                          ),
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
    );
  }
}
