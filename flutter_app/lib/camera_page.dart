// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/home_page.dart';
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
        (galleryStatus.isGranted || galleryStatus.isLimited)) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.max);
        await _controller!.initialize();
        await _controller!.lockCaptureOrientation();

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
    try{
      if (!_controller!.value.isInitialized) {
        return;
      }

      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        final XFile image = await _controller!.takePicture();

        navigateToPlantIdentificationPage(image.path);
      } else if (cameraStatus.isDenied || microphoneStatus.isDenied) {
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
      } else if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
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
    } catch(error){
      throw("Error: not enough permission with camera and microphone.");
    }
  }

  Future<void> _selectImageFromGallery() async {
    final galleryStatus = await Permission.photos.status;

    if (galleryStatus.isGranted || galleryStatus.isLimited){
      final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        navigateToPlantIdentificationPage(image.path);
      }
    } else {
      final statuses = await [
        Permission.photos
      ].request();

      if (statuses[Permission.photos]!.isDenied) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                  "Please enable camera, and gallery permissions in settings to use this feature."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      } else if (statuses[Permission.photos]!.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                  "You have permanently denied camera, and gallery permissions. Please enable them in device settings to use this feature."),
              actions: <Widget>[
                TextButton(
                  child: const Text("Open Settings"),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          }
        );
      }
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
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            dispose();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        title: const Text(
          "Take A Photo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
