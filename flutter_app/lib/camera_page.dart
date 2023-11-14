// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'plant_identification_page.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCameraAndMicrophoneAndGallery();
  }

  Future<void> _initializeCameraAndMicrophoneAndGallery() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final galleryStatus = await Permission.photos.status;

    if (cameraStatus.isGranted &&
        microphoneStatus.isGranted &&
        galleryStatus.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.max);
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } else {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.photos,
      ].request();

      if (statuses[Permission.camera]!.isGranted &&
          statuses[Permission.microphone]!.isGranted &&
          statuses[Permission.photos]!.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _controller = CameraController(cameras[0], ResolutionPreset.max);
          await _controller!.initialize();
          if (!mounted) return;
          setState(() {});
        } else if (statuses[Permission.camera]!.isDenied ||
            statuses[Permission.microphone]!.isDenied ||
            statuses[Permission.photos]!.isDenied) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Permission Denied"),
                  content: const Text(
                      "Please enable camera, microphone, and gallery permissions in settings to use this feature."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        } else if (statuses[Permission.camera]!.isPermanentlyDenied ||
            statuses[Permission.microphone]!.isPermanentlyDenied ||
            statuses[Permission.photos]!.isPermanentlyDenied) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Permission Denied"),
                  content: const Text(
                      "You have permanently denied camera, microphone, and gallery permissions. Please enable them in device settings to use this feature."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Open Settings"),
                      onPressed: () {
                        openAppSettings();
                      },
                    ),
                  ],
                );
              });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    final status = await Permission.camera.status;
    if (status.isGranted) {
      final XFile image = await _controller!.takePicture();

      navigateToPlantIdentificationPage(image.path);
    } else if (status.isDenied) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                  "Please enable camera permissions in settings to take a picture."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else if (status.isPermanentlyDenied) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                  "You have permanently denied camera permissions. Please enable them in device settings to use this feature."),
              actions: <Widget>[
                TextButton(
                  child: const Text("Open Settings"),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _selectImageFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      navigateToPlantIdentificationPage(image.path);
    }
  }

  void navigateToPlantIdentificationPage(String imagePath) {
    this.imagePath = imagePath;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlantIdentificationPage(imagePath: imagePath),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Take A Photo"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(_controller!),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _selectImageFromGallery,
                  child: const Icon(Icons.image_outlined,
                      color: Colors.white, size: 60),
                ),
                const SizedBox(
                  width: 90,
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
