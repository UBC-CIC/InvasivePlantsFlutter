// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'saved_plant_page.dart';
import 'package:provider/provider.dart';
import '../notifiers/plant_list_notifier.dart';
import 'dart:convert';
import '../functions/get_configuration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import '../notifiers/user_lists_notifier.dart';
import '../notifiers/plant_details_notifier.dart';

class PlantListPage extends StatefulWidget {
  final String listId;
  final String categoryTitle;

  const PlantListPage(
      {super.key, required this.categoryTitle, required this.listId});

  @override
  _PlantListPageState createState() => _PlantListPageState();
}

class _PlantListPageState extends State<PlantListPage> {
  late PlantListNotifier plantListNotifier;

  @override
  void initState() {
    super.initState();
    plantListNotifier =
        context.read<UserListsNotifier>().getOrCreateList(widget.listId);
    fetchData();
  }

  Future<String> _extractAccessToken() async {
    final rawResult = await Amplify.Auth.fetchAuthSession();
    final result = jsonDecode(rawResult.toString());
    final userPoolTokens = result['userPoolTokens'];

    try {
      final accessToken = extractAccessToken(userPoolTokens);
      return accessToken;
    } catch (e) {
      print('Error extracting access token: $e');
    }
    return "";
  }

  String extractAccessToken(String inputString) {
    final accessTokenStart =
        inputString.indexOf('"accessToken": "') + '"accessToken": "'.length;
    final accessTokenEnd = inputString.indexOf('"', accessTokenStart);
    return inputString.substring(accessTokenStart, accessTokenEnd);
  }

  Future<void> fetchData() async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList/${widget.listId}';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final response = await http.get(
        req,
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        setState(
          () {
            plantListNotifier.plants =
                List<String>.from(data[0]['saved_species']);
          },
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> removePlantFromSavedList(
      String listId, String listName, String scientificName) async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList/$listId';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final response = await http.get(
        req,
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(response.body);
        List<dynamic> savedSpecies =
            data.isNotEmpty ? data[0]['saved_species'] : [];

        // Check if the scientificName exists in the saved_species list
        if (savedSpecies.contains(scientificName)) {
          savedSpecies.removeWhere((species) =>
              species == scientificName); // Remove the specified species

          final body = jsonEncode({
            'list_name': listName,
            'saved_species': savedSpecies,
          });

          final putResponse = await http.put(
            req,
            headers: {
              'Authorization': accessToken,
            },
            body: body,
          );

          if (putResponse.statusCode != 200) {
            throw Exception('Failed to remove plant');
          }
          print(putResponse.body);
        }
      } else {
        throw Exception('Failed to load list data');
      }
    } catch (e) {
      print('Error removing plant: $e');
    }
  }

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantDetailsNotifier = Provider.of<PlantDetailsNotifier>(context);
    return ChangeNotifierProvider.value(
      value: plantListNotifier,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                widget.categoryTitle,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                onPressed: () {
                  plantDetailsNotifier
                      .setItemCount(plantListNotifier.plants.length);
                  Navigator.of(context).pop(
                    {
                      'itemCount': plantListNotifier.plants.length,
                    },
                  );
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Consumer2<PlantDetailsNotifier, PlantListNotifier>(
              builder: (context, details, plantList, _) {
                return ListView.builder(
                  itemCount: plantList.plants.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavedPlantPage(
                                  scientificName: plantList.plants[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 223, 250, 224),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: kElevationToShadow[3],
                            ),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.circle,
                                  size: 20,
                                  color: Color.fromARGB(255, 148, 201, 130),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatSpeciesName(
                                            plantList.plants[index]),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: -0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Delete Plant'),
                                            content: Text(
                                              'Are you sure you want to delete ${formatSpeciesName(plantList.plants[index])}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  removePlantFromSavedList(
                                                      widget.listId,
                                                      widget.categoryTitle,
                                                      plantList.plants[index]);
                                                  plantList.removePlant(index);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
