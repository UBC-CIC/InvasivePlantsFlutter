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
                      'assets/images/swordfern1.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 2.5, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/swordfern1.jpeg',
                        ),
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
                      'assets/images/swordfern2.jpeg',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(2.5, 0, 10, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/swordfern2.jpeg',
                        ),
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
                'assets/images/swordfern3.jpeg',
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/swordfern3.jpeg',
                  ),
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
              'Sword Fern',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Text(
              'Polystichum munitum',
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
                      'British Columbia’s moist and mild coastal climate provides ideal conditions for ferns to thrive, so much so that several fern species are obvious and characteristic features of the conifer forest floor. \n\nMost abundant of all these ferns is the stately and lush sword fern of the Wood Fern Family (Dryopteridaceae). Sword ferns grow into a large perennial clump of leaves spreading out from a massive crown. \n\nThis crown consists of a woody mass of rhizomes (root-stems) buried in reddish brown scales and dead leaf bases. \n\nRoots explore the soil outward from the rhizome. In a mature well-established clump the crown may stretch half a meter (20”) or more in diameter. \n\nDark evergreen fronds stand stiffly from the crown. Fronds reach as tall as 1.5 metres (60”) and up to 25 cm (10″) wide. The lower third of the frond consists of a den­sely scaly brown stalk, called a stipe by botanists. The upper two-thirds of the frond have numerous narrow, pointed and toothed leaflets. \n\nNear the tip of the frond the leaflets become progressively shorter. Young unfolding leaves are at first curled like a shepherd’s crook or crozier, then gradually un­furl and expand.',
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
