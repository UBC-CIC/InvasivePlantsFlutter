// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/camera_page.dart';

class APIResultPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> plantnetParams;
  final Map<String, dynamic> firstResult;
  final dynamic invasiveInfo;

  const APIResultPage(
      {super.key,
      required this.imagePath,
      required this.plantnetParams,
      required this.firstResult,
      this.invasiveInfo});

  @override
  State<APIResultPage> createState() => _APIResultPageState();
}

class _APIResultPageState extends State<APIResultPage> {
  @override
  void dispose() {
    // Clear images and organs when back button is pressed
    for (var key in widget.plantnetParams.keys.toList()) {
      if (key != 'service' && key != 'api-key') {
        widget.plantnetParams.remove(key);
      }
    }
    super.dispose();
    debugPrint('Plantnet Params: ${widget.plantnetParams}');
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.firstResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'RESULT',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'a',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
