// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../functions/wiki_webscrape.dart';
import '../global/GlobalVariables.dart';

class SavedPlantPage extends StatefulWidget {
  final String scientificName;
  const SavedPlantPage({
    super.key,
    required this.scientificName,
  });

  @override
  _SavedPlantPageState createState() => _SavedPlantPageState();
}

class _SavedPlantPageState extends State<SavedPlantPage>
    with AutomaticKeepAliveClientMixin<SavedPlantPage> {
  @override
  bool get wantKeepAlive => true;
  String firstImageURL = '';

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
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: AppColors.secondaryColor,
          ),
          title: Text(
            formatSpeciesName(widget.scientificName),
            style: const TextStyle(
                color: AppColors.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (firstImageURL != '') {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.network(
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
                  FutureBuilder<Map<String, Object>>(
                    future: webscrapeWikipedia(widget.scientificName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                            height: MediaQuery.of(context).size.height / 2.5,
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
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                            height: MediaQuery.of(context).size.height / 2.5,
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
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                            height: MediaQuery.of(context).size.height / 2.5,
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
                            (wikiInfo['speciesImages'] as List).isNotEmpty) {
                          final speciesImages =
                              wikiInfo['speciesImages'] as List?;
                          if (speciesImages != null &&
                              speciesImages.isNotEmpty) {
                            final firstImageURL = speciesImages[0] as String;
                            final lowerCaseImageUrl =
                                firstImageURL.toLowerCase();
                            if (lowerCaseImageUrl.endsWith('.jpg') ||
                                lowerCaseImageUrl.endsWith('.jpeg') ||
                                lowerCaseImageUrl.endsWith('.png')) {
                              return Container(
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(firstImageURL),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                width: double.infinity,
                              );
                            }
                          }
                        }
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                            height: MediaQuery.of(context).size.height / 2.5,
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
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, Object>>(
                future: webscrapeWikipedia(widget.scientificName),
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
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No Wikipedia info available'));
                  } else {
                    Map<String, Object> wikiInfo = snapshot.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
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
