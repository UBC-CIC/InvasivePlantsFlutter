import 'package:flutter/material.dart';
import 'plant_list_notifier.dart';
import 'get_configuration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListsNotifier extends ChangeNotifier {
  Map<String, PlantListNotifier> userLists = {};

  Future<void> addNewList(String listName) async {
    final newListName = listName; // Create a unique ID for the list
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final body = jsonEncode({'list_name': newListName, 'saved_species': []});
      final response = await http.post(
        req,
        headers: {
          'Authorization': accessToken,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var resDecode = jsonDecode(response.body);
        print('Result: $resDecode');

        if (resDecode.containsKey('list_id')) {
          var listIdValue = resDecode['list_id'];
          print('List ID: $listIdValue');

          // Update the PlantListNotifier with list name and list_id
          PlantListNotifier newList = PlantListNotifier();
          newList.setItemCount(0); // Set default item count
          newList.listName = newListName; // Assign list name
          newList.listId = listIdValue; // Assign list_id from response

          userLists[newListName] =
              newList; // Update userLists with new PlantListNotifier
          notifyListeners();
        } else {
          print('list_id not found in the response');
        }
      } else {
        print('Failed to send API request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending API request: $e');
    }
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

  Future<void> removeList(String listId, String listName) async {
    var configuration = getConfiguration();
    String? baseUrl = configuration["apiBaseUrl"];
    String endpoint = 'saveList/$listId';
    String apiUrl = '$baseUrl$endpoint';
    Uri req = Uri.parse(apiUrl);
    final accessToken = await _extractAccessToken();

    try {
      final response = await http.delete(
        req,
        headers: {
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        // Successful deletion, update local data
        if (userLists.containsKey(listId)) {
          userLists.remove(listId); // Remove locally created list
        } else {
          // Remove fetched list if exists
          String? fetchedListId;
          userLists.forEach(
            (key, value) {
              if (value.listName == listName) {
                fetchedListId = key;
              }
            },
          );
          if (fetchedListId != null) {
            userLists.remove(fetchedListId);
          }
        }
        notifyListeners(); // Notify listeners after deleting
      } else {
        print('Failed to delete list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending DELETE request: $e');
    }
  }

  PlantListNotifier getOrCreateList(String listId) {
    return userLists.putIfAbsent(listId, () => PlantListNotifier());
  }
}
