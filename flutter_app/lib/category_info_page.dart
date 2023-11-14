import 'package:flutter/material.dart';
import 'plant_info_from_category_page.dart';

class CategoryInfoPage extends StatefulWidget {
  final String categoryTitle;

  const CategoryInfoPage({super.key, required this.categoryTitle});

  @override
  State<CategoryInfoPage> createState() => _CategoryInfoPageState();
}

class _CategoryInfoPageState extends State<CategoryInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.categoryTitle,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(115, 0, 115, 10),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.blue),
              label:
                  const Text('Add Plant', style: TextStyle(color: Colors.blue)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        final plantIndex = 'Plant ${index + 1}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantInfoFromCategoryPage(
                                plantName: plantIndex),
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  8,
                                  (i) => Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        10, 10, 5, 10),
                                    width: 120,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      // image: const DecorationImage(
                                      //   image: AssetImage('assets/images/leaf.png'),
                                      //   fit: BoxFit.fill,
                                      // ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(
                              'Plant ${index + 1}',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      color: Color.fromARGB(255, 220, 220, 220),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
