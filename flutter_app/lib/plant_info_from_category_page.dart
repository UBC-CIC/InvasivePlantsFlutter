// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PlantInfoFromCategoryPage extends StatefulWidget {
  final String plantName;

  const PlantInfoFromCategoryPage({super.key, required this.plantName});

  @override
  _PlantInfoFromCategoryPageState createState() =>
      _PlantInfoFromCategoryPageState();
}

class _PlantInfoFromCategoryPageState extends State<PlantInfoFromCategoryPage>
    with AutomaticKeepAliveClientMixin<PlantInfoFromCategoryPage> {
  @override
  bool get wantKeepAlive => true;
  bool isBookmarked = false;

  void _showImageFullScreenDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

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
        title: const Text(
          'Plant Info',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showImageFullScreenDialog(
                      'assets/images/scotchbroom1.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 2.5, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/scotchbroom1.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showImageFullScreenDialog(
                      'assets/images/scotchbroom2.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(2.5, 0, 10, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/scotchbroom2.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _showImageFullScreenDialog(
                'assets/images/scotchbroom3.jpeg',
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/scotchbroom3.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              width: double.infinity,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              'Scotch Broom',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Text(
              'Cytisus scoparius',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 30),
                    child: Text(
                      'Scotch broom is a perennial evergreen shrub in the legume family. \n\nIt grows up to 10 feet tall. It has stiff, dark green branches, which grow more or less erect, and often have few leaves. The lower leaves have three lobes, while the upper leaves are simple. \n\nScotch broom has bright yellow flowers, which are shaped like pea flowers and are about ¾ inch long. The plants bloom from April to June, forming green seedpods, which turn black or brown as they mature. The pods each contain several seeds. There are several other introduced brooms, which are similar to Scotch broom and may also be invasive. \n\nScotch broom is a perennial evergreen shrub in the legume family. \n\nIt grows up to 10 feet tall. It has stiff, dark green branches, which grow more or less erect, and often have few leaves. The lower leaves have three lobes, while the upper leaves are simple. \n\nScotch broom has bright yellow flowers, which are shaped like pea flowers and are about ¾ inch long. The plants bloom from April to June, forming green seedpods, which turn black or brown as they mature. The pods each contain several seeds. There are several other introduced brooms, which are similar to Scotch broom and may also be invasive.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
