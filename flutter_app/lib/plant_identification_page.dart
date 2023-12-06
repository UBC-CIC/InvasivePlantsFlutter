// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/api_result_page.dart';
import 'package:flutter_app/camera_page.dart';
import 'package:flutter_app/plant_info_from_category_invasive_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PlantIdentificationPage extends StatefulWidget {
  final String imagePath;

  const PlantIdentificationPage({super.key, required this.imagePath});

  @override
  State<PlantIdentificationPage> createState() =>
      _PlantIdentificationPageState();
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  String? selectedOrgan;
  bool isItemSelected = false;
  // int imageCounter = 1;
  // int organCounter = 1;
  String baseUrl = 'https://my-api.plantnet.org/v2/identify/';
  String project = 'all';
  String includeRelatedImages = 'true';
  String lang = 'en';
  String noReject = 'true';
  String apiKey = '2b101Rx4lIHUaJFkbbPAccFmGO';
  bool isLoading = false; // Add this line to manage loading state

  Map<String, dynamic> plantnetParams = {
    'service': 'https://my-api.plantnet.org/v2/identify/all',
    'api-key': '2b101Rx4lIHUaJFkbbPAccFmGO',
    'organs': [],
    'images': [],
  };

  void _navigateToResultPage(BuildContext context) async {
    if (selectedOrgan != null) {
      setState(() {
        isLoading = true; // Set loading state to true when starting the request
      });

      _addImageAndOrganToParams();

      String url =
          '$baseUrl$project?include-related-images=$includeRelatedImages&no-reject=$noReject&lang=$lang&api-key=$apiKey';
      // debugPrint('URL: $url');

      // Create the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      // // Add images to the multipart request
      // for (var i = 0; i < plantnetParams['images'].length; i++) {
      File imageFile = File(plantnetParams['images'][0]);
      if (imageFile.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFile.path,
            filename: 'image_0.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        // debugPrint('added an image');
      }
      // }

      request.fields['organs'] = plantnetParams['organs'][0];

      // // add organs to the multipart request
      // for (var i = 0; i < plantnetParams['organs'].length; i++) {
      //   request.fields['organs'] = plantnetParams['organs'][i];
      //   debugPrint('added an organ');
      // }

      // debugPrint(request.toString());
      // debugPrint(request.headers.toString());
      // debugPrint(request.fields.toString());
      // debugPrint(request.fields['organs']?.length.toString());
      // debugPrint(request.fields['images']?.length.toString());

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var result = json.decode(responseData);

          // Extracting the first object from the "results" array
          Map<String, dynamic> firstResult = {};
          String? firstResultScientificName,
              firstResultCommonName,
              plantNetImageUrl,
              invasiveRegion,
              lowerCaseScientificName;

          if (result.containsKey('results') &&
              result['results'] is List &&
              result['results'].isNotEmpty) {
            firstResult = result['results'][0];

            firstResultScientificName =
                result['results'][0]['species']['scientificNameWithoutAuthor'];

            if (firstResult['species'].containsKey('commonNames') &&
                firstResult['species']['commonNames'] is List &&
                firstResult['species']['commonNames'].isNotEmpty) {
              firstResultCommonName = result['results'][0]['species']
                      ['commonNames'][0]
                  .replaceAll('-', ' ');
            } else {
              firstResultCommonName = firstResultScientificName;
            }

            plantNetImageUrl = result['results'][0]['images'][0]['url']['o'];

            // Formatting firstResultName
            if (firstResultScientificName != null) {
              lowerCaseScientificName =
                  firstResultScientificName.toLowerCase().replaceAll(' ', '_');
            } else {
              debugPrint('Invalid first result format.');
            }

            try {
              // Create the URL for the GET request
              final apiUrl =
                  'https://p2ltjqaajb.execute-api.ca-central-1.amazonaws.com/prod/invasiveSpecies?scientific_name=$lowerCaseScientificName';

              // Make the GET request
              var getResponse = await http.get(Uri.parse(apiUrl));

              if (getResponse.statusCode == 200) {
                // Parse the response body
                var parsedResponse = json.decode(getResponse.body);

                var matchingInvasiveSpecies = parsedResponse[0];
                var invasiveRegionId = parsedResponse[0]['region_id'][0];

                if (invasiveRegionId ==
                    '7ae91c1e-3444-42b9-83a9-c0d9e25d1981') {
                  invasiveRegion = 'British Columbia';
                } else if (invasiveRegionId ==
                    '82c70f8d-e00a-47af-a312-e5dda299e1af') {
                  invasiveRegion = 'Ontario';
                }

                debugPrint("matchingInvasiveSpecies: $matchingInvasiveSpecies");
                debugPrint("firstResultCommonName: $firstResultCommonName");
                debugPrint("invasiveRegionId: $invasiveRegion");
                debugPrint("plantNetImageUrl: $plantNetImageUrl");

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlantInfoFromCategoryInvasivePage(
                      speciesObject: matchingInvasiveSpecies,
                      commonName: firstResultCommonName,
                      regionId: invasiveRegion,
                      plantNetImageURL: plantNetImageUrl,
                    ),
                  ),
                );
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => APIResultPage(
                //         imagePath: widget.imagePath,
                //         plantnetParams: plantnetParams,
                //         firstResult: firstResult,
                //         invasiveInfo: parsedResponse),
                //   ),
                // );
              } else {
                debugPrint(
                    'GET Request failed with status: ${getResponse.statusCode}');
              }
            } catch (e) {
              debugPrint('Exception during GET request: $e');
              debugPrint(firstResultCommonName);
              debugPrint(plantNetImageUrl);
              debugPrint(firstResultScientificName);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => APIResultPage(
                          commonName: firstResultCommonName,
                          scientificName: firstResultScientificName,
                          imageUrl: plantNetImageUrl,
                        )),
              );
            }
          }
        } else {
          var responseData = await response.stream.bytesToString();
          debugPrint('Request failed with status: ${responseData.toString()}');
        }
      } catch (e) {
        debugPrint('Exception during POST request: $e');
        debugPrint(request.fields.toString());
        debugPrint(request.fields['organs'].toString());
        debugPrint(request.fields['images'].toString());

        debugPrint(request.headers.toString());
        debugPrint(request.files.toString());
      } finally {
        setState(() {
          isLoading =
              false; // Set loading state to false when request completes
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text(
            'Please select an organ first',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addImageAndOrganToParams() {
    // if (imageCounter <= 5 && organCounter <= 5) {
    if (selectedOrgan != null) {
      plantnetParams['organs'].add(selectedOrgan!.toLowerCase());
      plantnetParams['images'].add(widget.imagePath);
      // imageCounter++;
      // organCounter++;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text(
            'Please select an organ first',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    // }
    //else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       duration: const Duration(milliseconds: 1000),
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       content: const Text('You have uploaded the maximum amount of photos'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // debugPrint('Plantnet Params: $plantnetParams');
  }

  @override
  void dispose() {
    // Clear images and organs when back button is pressed
    for (var key in plantnetParams.keys.toList()) {
      if (key != 'service' && key != 'api-key') {
        plantnetParams.remove(key);
      }
    }
    super.dispose();
    // debugPrint('Plantnet Params: $plantnetParams');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            dispose();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CameraPage(),
              ),
            );
          },
        ),
        title: const Text(
          'SELECT PLANT ORGAN',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 390,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                children: [
                  _buildGridItem("LEAF", 'assets/images/leaf.png'),
                  _buildGridItem("FLOWER", 'assets/images/flower.png'),
                  _buildGridItem("FRUIT", 'assets/images/fruit.png'),
                  _buildGridItem("BARK", 'assets/images/bark.png'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Expanded(
                  //   child: Container(
                  //     margin: const EdgeInsets.fromLTRB(7, 2, 5, 4),
                  //     child: ElevatedButton.icon(
                  //       onPressed: () {
                  //         _addImageAndOrganToParams();
                  //       },
                  //       icon: const Icon(Icons.add, color: Colors.black),
                  //       label: const Text('Upload Another',
                  //           style: TextStyle(color: Colors.black)),
                  //       style: ElevatedButton.styleFrom(
                  //         foregroundColor: Colors.black,
                  //         backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _navigateToResultPage(context);
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text('Find Matches',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isItemSelected
                              ? Colors.green
                              : const Color.fromARGB(255, 221, 221, 221),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Identifying Species...',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String text, String imageUrl) {
    bool isSelected = selectedOrgan == text;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            if (isSelected) {
              selectedOrgan = null;
              isItemSelected = false;
            } else {
              selectedOrgan = text;
              isItemSelected = true;
            }
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 60,
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
