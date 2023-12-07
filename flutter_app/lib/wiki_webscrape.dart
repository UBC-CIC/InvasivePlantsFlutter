import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

const String mediaWikiApiEndpoint_baseURL = 'en.wikipedia.org';
const String mediaWikiApiEndpoint_path = '/w/api.php';

Future<Map<String, Object>> webscrapeWikipedia(String scientificName) async {
  try {
    var params = {
      'action': 'query',
      'format': 'json',
      'titles': scientificName,
      'prop': 'extracts|images',
      'redirects': 'true',
      'exintro': 'true',
      'explaintext': 'true',
      'imlimit': '15',
    };

    var response = await http.get(Uri.https(mediaWikiApiEndpoint_baseURL, mediaWikiApiEndpoint_path, params));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    var data = json.decode(response.body);
    var pages = data['query']['pages'];
    print('data: ${pages.toString()}');

    // Handles redirected pages
    String redirectedPageTitleName = scientificName;
    if (data['query']['redirects'] != null && data['query']['redirects'].length > 0) {
      redirectedPageTitleName = data['query']['redirects'][0]['to'];
    }

    if (pages == null || pages.keys.isEmpty) {
      throw Exception("Species not found on Wikipedia.");
    }

    // Determine page information
    String pageId = pages.keys.first;
    var page = pages[pageId];

    // Get all sections and its value
    var sections = await fetchSections(pageId);
    var sectionData = [];
    for(int i = 0; i < sections.length; i++){
      String sectionTitle = sections[i]["line"].toString();
      if(!sectionTitle.contains("References")){
        String sectionValue = await fetchSectionContent(pageId, sections[i]["index"]);
        sectionData.add({
          "header": sections[i]["line"],
          "body": sectionValue
        });
      }
    }

    // Get images from wiki
    List<String> imageInfo;
    if (page['images'] != null && page['images'] is List) {
      imageInfo = await fetchImageUrls(page['images'], scientificName, redirectedPageTitleName);
    } else {
      imageInfo = [];
    }

    // gets overview, description, images, and the link of Wiki page
		var wikiInfo = {
			'overview': cleanUpString(page["extract"]),
			'body': sectionData,
			'speciesImages': imageInfo,
			'wikiUrl': 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(scientificName)}',
		};

    // Return the final wikiInfo map
    return wikiInfo;
  } catch (error) {
    print('Error while fetching Wikipedia data: ${error.toString()}');
    return {};
  }
}


// gets the sections of a Wikipedia page using the MediaWiki API
Future<List<dynamic>> fetchSections(String pageId) async {
  var sectionsParams = {
    'action': 'parse',
    'format': 'json',
    'pageid': pageId,
    'prop': 'sections',
  };

  var uri = Uri.https(mediaWikiApiEndpoint_baseURL, mediaWikiApiEndpoint_path, sectionsParams);
  var response = await http.get(uri);

  print('response: ${response}');

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['parse']['sections'] ?? [];
  } else {
    // Handle the case when the server returns a non-200 status code.
    print('Request failed with status: ${response.statusCode}.');
    return [];
  }
}

Future<String> fetchSectionContent(String pageId, String sectionIndex) async {
  var sectionParams = {
    'action': 'parse',
    'format': 'json',
    'pageid': pageId,
    'prop': 'text',
    'section': sectionIndex,
  };

  // Make HTTP request
  var uri = Uri.https(mediaWikiApiEndpoint_baseURL, mediaWikiApiEndpoint_path, sectionParams);
  var sectionResponse = await http.get(uri);

  if (sectionResponse.statusCode == 200) {
    // Clean up the response
    var data = json.decode(sectionResponse.body);
    String content = data['parse']['text']['*'];

    List<String> speciesDescription = [];

    // Get only the text
    var document = parse(content);

    document.querySelectorAll('p').forEach((Element pElement) {
      // Check if the paragraph does not contain a <style> tag with the specified class
      if (pElement.querySelectorAll('style[data-mw-deduplicate="TemplateStyles:r1154941027"]').isEmpty) {
        speciesDescription.add(pElement.text);
      }
    });

    return cleanUpString(speciesDescription.join("\n"));
  } else {
    // Handle the case when the server returns a non-200 status code.
    print('Request failed with status: ${sectionResponse.statusCode}.');
    return "";
  }
}

// gets 5 image URLs from Wikipedia using the MediaWiki API
Future<List<String>> fetchImageUrls(List images, String prevTitle, String pageTitle) async {
  List<String> imageUrls = [];
  var matchNameRedirectedTitle = pageTitle.split(' ').map(Uri.encodeComponent).toList();
  var matchNameOriginalTitle = prevTitle.split(' ').map(Uri.encodeComponent).toList();
  int numImage = 0;

  for (var image in images) {
    if (numImage >= 5) {
      break;
    }

    var imageParams = {
      'action': 'query',
      'format': 'json',
      'titles': image['title'],  // Assuming 'image' is a Map with a 'title' key
      'prop': 'imageinfo',
      'iiprop': 'url',
    };

    var uri = Uri.https(mediaWikiApiEndpoint_baseURL, mediaWikiApiEndpoint_path, imageParams);
    var response = await http.get(uri);
    var data = jsonDecode(response.body);
    var pages = data['query']['pages'];
    var pageId = pages.keys.first;
    var page = pages[pageId];

    if (page != null &&
        page['imageinfo'] != null &&
        page['imageinfo'][0]['url'] != null &&
        (matchNameRedirectedTitle.any((name) => Uri.decodeComponent(page['imageinfo'][0]['url']).toLowerCase().contains(name)) ||
         matchNameOriginalTitle.any((name) => Uri.decodeComponent(page['imageinfo'][0]['url']).toLowerCase().contains(name)))) {
      imageUrls.add(page['imageinfo'][0]['url']);
      numImage++;
    }
  }
  return imageUrls;
}



// helper function to clean up data
String cleanUpString(dynamic input) {
  // Convert to string if not already
  String result = input.toString();

  // Remove brackets []
  result = result.replaceAll(RegExp(r'\[.*?\]'), '');

  // Remove parentheses ()
  result = result.replaceAll(RegExp(r'\(|\)'), '');

  // Remove commas preceded by a line break and divide with a new line
  result = result.replaceAll(RegExp(r'(\r\n|\n)\s*,', multiLine: true), r"$1\n");

  return result.trim();
}
