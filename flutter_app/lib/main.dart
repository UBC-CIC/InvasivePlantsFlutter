import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:flutter_app/sign_up_page.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'category_info_page.dart';
import 'plant_info_from_category_page.dart';
import 'camera_page.dart';
import 'plant_identification_page.dart';
import 'my_plants_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';
import 'lib.dart';

import 'package:flutter/services.dart'; // Import SystemChrome class

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that the binding is initialized
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // Lock to portrait mode

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserListsNotifier()),
        ChangeNotifierProvider(create: (_) => PlantDetailsNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      final amplifyConfigString = jsonDecode(amplifyconfig);
      var configuration = getConfiguration();
      String? poolId = configuration["cognitoPoolId"];
      String? clientId = configuration["cognitAppClientId"];
      String? region = configuration["cognitoRegion"];

      amplifyConfigString["auth"]["plugins"]["CognitoUserPool"]["Default"]
          ["PoolId"] = poolId;
      amplifyConfigString["auth"]["plugins"]["CognitoUserPool"]["Default"]
          ["AppClientId"] = clientId;
      amplifyConfigString["auth"]["plugins"]["CognitoUserPool"]["Default"]
          ["Region"] = region;

      var configString = json.encode(amplifyConfigString);
      print(configString);

      await Amplify.configure(json.encode(amplifyConfigString));
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Identification App',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(
              profileImagePath: '',
            ),
        '/categoryInfo': (context) => const CategoryInfoPage(
              categoryTitle: '',
              listId: '',
            ),
        '/plantInfoFromCategory': (context) => const PlantInfoFromCategoryPage(
              speciesObject: {},
            ),
        '/camera': (context) => const CameraPage(),
        '/plantIdentification': (context) => const PlantIdentificationPage(
              imagePath: '',
            ),
        '/myPlants': (context) => const MyPlantsPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LogInPage(),
      },
    );
  }
}
