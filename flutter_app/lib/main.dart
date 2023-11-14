import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'category_info_page.dart';
import 'plant_info_from_category_page.dart';
import 'camera_page.dart';
import 'plant_identification_page.dart';
import 'my_plants_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserListsNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Identification App',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(
              profileImagePath: '',
            ),
        '/categoryInfo': (context) => const CategoryInfoPage(
              categoryTitle: '',
            ),
        '/plantInfoFromCategory': (context) => const PlantInfoFromCategoryPage(
              plantName: '',
            ),
        '/camera': (context) => const CameraPage(),
        '/plantIdentification': (context) => const PlantIdentificationPage(
              imagePath: '',
            ),
        '/myPlants': (context) => const MyPlantsPage(),
      },
    );
  }
}
