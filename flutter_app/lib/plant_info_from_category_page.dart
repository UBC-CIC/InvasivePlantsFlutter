// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Import dart:convert to use utf8 decoding

class PlantInfoFromCategoryPage extends StatefulWidget {
  final Map<String, dynamic> speciesObject; // Define speciesObject here
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
  bool isBookmarked = false;

  void _showImageFullScreenDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
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
    return Scaffold(
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
                imageUrl,
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              utf8.decode(formatSpeciesName(scientificName).codeUnits),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
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
                            'For more info:',
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
    );
  }
}
