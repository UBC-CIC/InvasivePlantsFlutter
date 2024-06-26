// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:io';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/functions/get_credentials.dart';
import 'non_invasive_plant_page.dart';
import 'camera_page.dart';
import 'invasive_plant_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../functions/get_configuration.dart';
import '../global/GlobalVariables.dart';

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
  String baseUrl = 'https://my-api.plantnet.org/v2/identify/';
  String project = 'all';
  String includeRelatedImages = 'true';
  String lang = 'en';
  String noReject = 'true';
  bool isLoading = false;

  Map<String, dynamic> plantnetParams = {
    'organs': [],
    'images': [],
  };

  String extractAccessToken(String inputString) {
    final accessTokenStart =
        inputString.indexOf('"accessToken": "') + '"accessToken": "'.length;
    final accessTokenEnd = inputString.indexOf('"', accessTokenStart);
    return inputString.substring(accessTokenStart, accessTokenEnd);
  }

  void _navigateToResultPage(BuildContext context) async {
    if (selectedOrgan != null) {
      setState(() {
        isLoading = true; // Set loading state to true when starting the request
      });

      _addImageAndOrganToParams();

      var configuration = getConfiguration();
      String apiKey = configuration["plantnetAPIKey"]!;
      String url =
          '$baseUrl$project?include-related-images=$includeRelatedImages&no-reject=$noReject&lang=$lang&api-key=$apiKey';

      // Create the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add images to the multipart request
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
      }

      request.fields['organs'] = plantnetParams['organs'][0];

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
              lowerCaseScientificName,
              accuracyScoreString;
          double? accuracyScoreRaw;

          if (result.containsKey('results') &&
              result['results'] is List &&
              result['results'].isNotEmpty) {
            firstResult = result['results'][0];

            accuracyScoreRaw = firstResult['score'] * 100;
            accuracyScoreString = '${accuracyScoreRaw?.toStringAsFixed(0)}%';

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
              var configuration = getConfiguration();
              String? baseUrl = configuration["apiBaseUrl"];
              final credentials = await getCredentials();

              if (lowerCaseScientificName != null &&
                  lowerCaseScientificName.isNotEmpty &&
                  selectedRegion["region_id"] != null) {
                final awsSigV4Client = AwsSigV4Client(credentials.accessKeyId,
                    credentials.secretAccessKey, baseUrl!,
                    sessionToken: credentials.sessionToken,
                    region: configuration["cognitoRegion"]!);

                final signedRequest = SigV4Request(awsSigV4Client,
                    method: 'GET',
                    path: 'invasiveSpecies',
                    queryParams: {
                      'search_input': lowerCaseScientificName.toString(),
                      'region_id': selectedRegion["region_id"].toString(),
                    });

                final getResponse = await http.get(
                  Uri.parse(signedRequest.url!),
                  headers: signedRequest.headers!
                      .map((key, value) => MapEntry(key, value ?? "")),
                );

                if (getResponse.statusCode == 200) {
                  // Parse the response body
                  var parsedResponse = json.decode(getResponse.body);

                  var matchingInvasiveSpecies = parsedResponse["species"][0];
                  var invasiveRegion =
                      matchingInvasiveSpecies['region_code_names'].join(', ');

                  debugPrint(
                      "matchingInvasiveSpecies: $matchingInvasiveSpecies");
                  debugPrint("firstResultCommonName: $firstResultCommonName");
                  debugPrint("invasiveRegionId: $invasiveRegion");
                  debugPrint("plantNetImageUrl: $plantNetImageUrl");

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InvasivePlantPage(
                          speciesObject: matchingInvasiveSpecies,
                          commonName: firstResultCommonName,
                          regionId: invasiveRegion,
                          plantNetImageURL: plantNetImageUrl,
                          accuracyScoreString: accuracyScoreString),
                    ),
                  );
                } else {
                  debugPrint(
                      'GET Request failed with status: ${getResponse.statusCode}');
                }
              }
            } catch (e) {
              debugPrint('Exception during GET request: $e');
              debugPrint(firstResultCommonName);
              debugPrint(plantNetImageUrl);
              debugPrint(firstResultScientificName);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => NonInvasivePlantPage(
                        commonName: firstResultCommonName,
                        scientificName: firstResultScientificName,
                        imageUrl: plantNetImageUrl,
                        accuracyScoreString: accuracyScoreString)),
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
    if (selectedOrgan != null) {
      plantnetParams['organs'].add(selectedOrgan!.toLowerCase());
      plantnetParams['images'].add(widget.imagePath);
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

  @override
  void dispose() {
    // Clear images and organs when back button is pressed
    for (var key in plantnetParams.keys.toList()) {
      if (key != 'service' && key != 'api-key') {
        plantnetParams.remove(key);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.clear, color: AppColors.secondaryColor),
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
              color: AppColors.primaryColor,
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
                                ? AppColors.primaryColor
                                : AppColors.secondaryColor,
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
