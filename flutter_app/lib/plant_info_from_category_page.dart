// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'home_page.dart';
import 'my_plants_page.dart';

class PlantInfoFromCategoryPage extends StatefulWidget {
  final String plantName;

  const PlantInfoFromCategoryPage({super.key, required this.plantName});

  @override
  _PlantInfoFromCategoryPageState createState() =>
      _PlantInfoFromCategoryPageState();
}

class _PlantInfoFromCategoryPageState extends State<PlantInfoFromCategoryPage> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.plantName), // Plant name as app bar title
        actions: [
          IconButton(
            icon: isBookmarked
                ? const Icon(Icons.bookmark)
                : const Icon(Icons.bookmark_border),
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.grey,
                  height: MediaQuery.of(context).size.height / 3,
                  child: const Center(
                    child: Text('Left Rectangle'), // Left-side content
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey,
                          height: MediaQuery.of(context).size.height / 6,
                          child: const Center(
                            child:
                                Text('Top Right Square'), // Top-right content
                          ),
                        ),
                        Container(
                          color: Colors.grey,
                          height: MediaQuery.of(context).size.height / 6,
                          child: const Center(
                            child: Text(
                                'Bottom Right Square'), // Bottom-right content
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          DefaultTabController(
            length: 3, // Number of tabs
            child: Column(
              children: <Widget>[
                const TabBar(
                  tabs: [
                    Tab(text: 'About'),
                    Tab(text: 'Characteristics'),
                    Tab(text: 'Control'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: TabBarView(
                    children: [
                      Center(child: Text('About ${widget.plantName}')),
                      Center(
                          child:
                              Text('Characteristics of ${widget.plantName}')),
                      Center(
                          child:
                              Text('Control procedure of ${widget.plantName}')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
