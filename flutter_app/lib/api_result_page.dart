// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_app/camera_page.dart';

class APIResultPage extends StatefulWidget {
  final String? commonName, scientificName, imageUrl, accuracyScoreString;

  const APIResultPage(
      {super.key,
      this.commonName,
      this.scientificName,
      this.imageUrl,
      this.accuracyScoreString});

  @override
  _APIResultPageState createState() => _APIResultPageState();
}

class _APIResultPageState extends State<APIResultPage>
    with AutomaticKeepAliveClientMixin<APIResultPage> {
  @override
  bool get wantKeepAlive => true;
  bool isBookmarked = false;

  void _showImageFullScreenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CameraPage(),
              ),
            );
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_box,
              color: Colors.green,
            ),
            Text(
              ' Safe Plant ',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.check_box,
              color: Colors.green,
            ),
          ],
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
          GestureDetector(
            onTap: () {
              _showImageFullScreenDialog();
            },
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    margin: const EdgeInsets.fromLTRB(115, 5, 115, 10),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Accuracy: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.accuracyScoreString!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text(
              widget.commonName!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              widget.scientificName!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Text(
                      "“Elephant ears” is the common name for a group of tropical perennial plants grown for their large, heart-shaped leaves. Most of these herbaceous species in the arum or aroid family (Araceae) that are offered as ornamentals belong to the genera Colocasia, Alocasia, and Xanthosoma, although there are others that have similar appearance and growth habits.\n\nThe first two genera are native to tropical southern Asia, Indonesia, Malaysia, New Guinea, parts of Australia, or the Pacific Islands, while Xanthosoma is native to tropical America. Many of the species have long been grown for the edible starchy corms or tubers as an important staple food in tropical regions.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
