import 'dart:io';
import 'package:flutter/material.dart';

class APIResultPage extends StatefulWidget {
  final String imagePath;
  final String selectedOrgan;

  const APIResultPage({
    super.key,
    required this.imagePath,
    required this.selectedOrgan,
  });

  @override
  State<APIResultPage> createState() => _APIResultPageState();
}

class _APIResultPageState extends State<APIResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selected Organ: ',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                widget.selectedOrgan,
                style: const TextStyle(
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
