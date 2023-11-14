import 'dart:io';
import 'package:flutter/material.dart';

class PlantIdentificationPage extends StatefulWidget {
  final String imagePath;

  const PlantIdentificationPage({super.key, required this.imagePath});

  @override
  State<PlantIdentificationPage> createState() =>
      _PlantIdentificationPageState();
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'SELECT PLANT ORGAN',
          style: TextStyle(color: Colors.black),
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
                      debugPrint("+ Upload Another");
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
                      debugPrint("Find Matches");
                    },
                    icon: const Icon(Icons.search, color: Colors.black),
                    label: const Text('Find Matches',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String text, String imageUrl) {
    return GestureDetector(
      onTap: () {
        debugPrint(text);
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
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
