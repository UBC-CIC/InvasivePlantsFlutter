// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_app/camera_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wiki_webscrape.dart';

class APIResultPage extends StatefulWidget {
  final String? commonName, scientificName, imageUrl, accuracyScoreString;

  const APIResultPage(
      {super.key,
      this.commonName,
      this.scientificName,
      this.imageUrl,
      this.accuracyScoreString});

  @override
  _APIResultPageState createState() => _APIResultPageState();
}

class _APIResultPageState extends State<APIResultPage>
    with AutomaticKeepAliveClientMixin<APIResultPage> {
  @override
  bool get wantKeepAlive => true;
  bool isBookmarked = false;

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
              color: Colors.green,
            ),
            Text(
              ' Safe Plant ',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.check_box,
              color: Colors.green,
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              widget.scientificName!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Overview',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 274, 0),
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
                                  final body = wikiInfo['body'] as List?;
                                  if (body != null && index < body.length) {
                                    final header = body[index]?['header'] ?? '';
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 294, 0),
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
                                  itemCount: (wikiInfo['speciesImages'] as List)
                                      .length,
                                  itemBuilder: (context, index) {
                                    final speciesImages =
                                        wikiInfo['speciesImages'] as List?;
                                    if (speciesImages != null &&
                                        index < speciesImages.length) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Image.network(
                                                  speciesImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 5, 5),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Link',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 321, 0),
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
    );
  }
}
