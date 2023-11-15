// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PlantInfoFromCategoryInvasivePage extends StatefulWidget {
  final String plantName;

  const PlantInfoFromCategoryInvasivePage({super.key, required this.plantName});

  @override
  _PlantInfoFromCategoryInvasivePageState createState() =>
      _PlantInfoFromCategoryInvasivePageState();
}

class _PlantInfoFromCategoryInvasivePageState
    extends State<PlantInfoFromCategoryInvasivePage>
    with AutomaticKeepAliveClientMixin<PlantInfoFromCategoryInvasivePage> {
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
          'Scotch Broom',
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
                child: GestureDetector(
                  onTap: () {
                    _showImageFullScreenDialog(
                      'assets/images/scotchbroom1.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 3, 5),
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
                    margin: const EdgeInsets.fromLTRB(3, 0, 10, 5),
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
          Expanded(
            child: DefaultTabController(
              length: 1,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Colors.lightBlue,
                          Colors.lightBlue,
                        ]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tabs: const [
                        Tab(
                          text: 'About',
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  'Scotch Broom',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  'Cytisus scoparius',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 30),
                                child: Text(
                                  'Scotch broom is a perennial evergreen shrub in the legume family. \n\nIt grows up to 10 feet tall. It has stiff, dark green branches, which grow more or less erect, and often have few leaves. The lower leaves have three lobes, while the upper leaves are simple. \n\nScotch broom has bright yellow flowers, which are shaped like pea flowers and are about ¾ inch long. The plants bloom from April to June, forming green seedpods, which turn black or brown as they mature. The pods each contain several seeds. There are several other introduced brooms, which are similar to Scotch broom and may also be invasive. \n\nScotch broom is a perennial evergreen shrub in the legume family. \n\nIt grows up to 10 feet tall. It has stiff, dark green branches, which grow more or less erect, and often have few leaves. The lower leaves have three lobes, while the upper leaves are simple. \n\nScotch broom has bright yellow flowers, which are shaped like pea flowers and are about ¾ inch long. The plants bloom from April to June, forming green seedpods, which turn black or brown as they mature. The pods each contain several seeds. There are several other introduced brooms, which are similar to Scotch broom and may also be invasive.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
