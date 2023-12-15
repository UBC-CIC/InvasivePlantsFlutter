// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app/camera_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Import dart:convert to use utf8 decoding

import 'package:flutter_app/plant_info_from_category_page.dart';
import 'wiki_webscrape.dart';

class PlantInfoFromCategoryInvasivePage extends StatefulWidget {
  final Map<String, dynamic> speciesObject;
  final String? commonName, regionId, plantNetImageURL, accuracyScoreString;

  const PlantInfoFromCategoryInvasivePage(
      {super.key,
      required this.speciesObject,
      this.commonName,
      this.regionId,
      this.plantNetImageURL,
      this.accuracyScoreString});

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
              child: widget.plantNetImageURL != null
                  ? Image.network(
                      widget.plantNetImageURL!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
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
    // Ensure UTF-8 decoding for the species description to remove special characters
    String speciesDescription = utf8.decode(
      widget.speciesObject['species_description'].codeUnits,
    );

    List<String> resourceLinks =
        List<String>.from(widget.speciesObject['resource_links'] ?? []);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: widget.plantNetImageURL != null
                        ? DecorationImage(
                            image: NetworkImage(widget.plantNetImageURL!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image:
                                AssetImage('assets/images/scotchbroom3.jpeg'),
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
          Expanded(
            child: DefaultTabController(
              length: 3,
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
                                    const EdgeInsets.fromLTRB(10, 5, 10, 0),
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  formatSpeciesName(scientificName),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                              if (widget.regionId != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: Colors.green,
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
                                              color: Colors.green,
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
                                                    body[index]?['body'] ?? '';

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
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        bodyContent,
                                                        style: const TextStyle(
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
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
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
                                                        speciesImages.length) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => Dialog(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                Image.network(
                                                              speciesImages[
                                                                  index],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(5, 5, 5, 5),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          speciesImages[index],
                                                          width: 150,
                                                          height: 150,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  );
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
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Link',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 321, 0),
                                            child: Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.green,
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
                                                wikiInfo['wikiUrl']!.toString(),
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
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
                                        : alternativeSpecies['scientific_name']
                                            [0];

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
                                                PlantInfoFromCategoryPage(
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
                                              color:
                                                  Colors.grey.withOpacity(0.5),
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
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Color.fromARGB(
                                                            255, 43, 75, 90),
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
    );
  }
}
