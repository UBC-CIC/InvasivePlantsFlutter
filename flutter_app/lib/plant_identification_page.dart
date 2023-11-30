import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/api_result_page.dart';
import 'package:flutter_app/camera_page.dart';

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
  int imageCounter = 1;
  int organCounter = 1;

  Map<String, String> plantnetParams = {
    'service': 'https://my-api.plantnet.org/v2/identify/all',
    'api-key': 'api-key=2b101Rx4lIHUaJFkbbPAccFmGO',
  };

  void _navigateToResultPage(BuildContext context) {
    if (selectedOrgan != null) {
      _addImageAndOrganToParams();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => APIResultPage(
              imagePath: widget.imagePath,
              plantnetParams: plantnetParams,
              imageCounter: imageCounter,
              organCounter: organCounter),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text('Please select an organ first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addImageAndOrganToParams() {
    final imagePathKey = 'image_$imageCounter';
    final organKey = 'organ_$organCounter';

    if (imageCounter <= 5 && organCounter <= 5) {
      if (selectedOrgan != null &&
          !plantnetParams.containsValue(widget.imagePath) &&
          !plantnetParams.containsValue(selectedOrgan)) {
        plantnetParams[organKey] = 'organs=${selectedOrgan!.toLowerCase()}';
        plantnetParams[imagePathKey] = 'images=${widget.imagePath}';
        imageCounter++;
        organCounter++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: const Text('Please select an organ first'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text('You have uploaded the maximum amount of photos'),
          backgroundColor: Colors.red,
        ),
      );
    }

    debugPrint('Plantnet Params: $plantnetParams');
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
    debugPrint('Plantnet Params: $plantnetParams');
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
      body: Column(
        children: <Widget>[
          Container(
            height: 260,
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
            childAspectRatio: 1.5,
            children: [
              _buildGridItem("LEAF", 'assets/images/leaf.png'),
              _buildGridItem("FLOWER", 'assets/images/flower.png'),
              _buildGridItem("FRUIT", 'assets/images/fruit.png'),
              _buildGridItem("BARK", 'assets/images/bark.png'),
              _buildGridItem("HABITAT", 'assets/images/habit.png'),
              _buildGridItem("OTHER", 'assets/images/other.png'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(7, 2, 5, 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _addImageAndOrganToParams();
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Upload Another',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 2, 7, 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _navigateToResultPage(context);
                    },
                    icon: const Icon(Icons.search, color: Colors.black),
                    label: const Text('Find Matches',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
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
          borderRadius: BorderRadius.circular(5),
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
