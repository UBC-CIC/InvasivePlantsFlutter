// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_app/plant_info_from_category_page.dart';

class PlantInfoFromCategoryInvasivePage extends StatefulWidget {
  final Map<String, dynamic> speciesObject; // Define speciesObject here

  const PlantInfoFromCategoryInvasivePage({
    super.key,
    required this.speciesObject,
  });

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
    String speciesDescription = widget.speciesObject['species_description'];
    List<String> resourceLinks =
        List<String>.from(widget.speciesObject['resource_links'] ?? []);
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
              height: MediaQuery.of(context).size.height / 2.5,
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
                                      scientificName), // Handle null case
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  'Common Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                child: Text(
                                  speciesDescription,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              if (resourceLinks.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'For more info:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
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
                              const SizedBox(height: 50),
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
