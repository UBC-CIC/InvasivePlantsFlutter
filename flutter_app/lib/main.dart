import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:flutter_app/sign_up_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'plant_list_page.dart';
import 'alternative_plant_page.dart';
import 'camera_page.dart';
import 'plant_identification_page.dart';
import 'saved_lists_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'AmplifyConfiguration.dart';
import 'GetConfigs.dart';

import 'package:flutter/services.dart'; // Import SystemChrome class

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that the binding is initialized
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // Lock to portrait mode

  Future<void> configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      final amplifyConfigString = jsonDecode(amplifyconfig);
      var configuration = getConfiguration();
      String? poolId = configuration["cognitoPoolId"];
      String? clientId = configuration["cognitoAppClientId"];
      String? region = configuration["cognitoRegion"];

      if (amplifyConfigString != null &&
          poolId != null &&
          clientId != null &&
          region != null) {
        // amplifyConfigString.auth.plugins.awsCognitoAuthPlugin.CognitoUserPool.Default.PoolId = poolId;
        amplifyConfigString["auth"]["plugins"]["awsCognitoAuthPlugin"]
            ["CognitoUserPool"]["Default"]["PoolId"] = poolId;
        amplifyConfigString["auth"]["plugins"]["awsCognitoAuthPlugin"]
            ["CognitoUserPool"]["Default"]["AppClientId"] = clientId;
        amplifyConfigString["auth"]["plugins"]["awsCognitoAuthPlugin"]
            ["CognitoUserPool"]["Default"]["Region"] = region;

        var configString = json.encode(amplifyConfigString);
        print(configString);

        await Amplify.configure(json.encode(amplifyConfigString));
      } else {
        throw Exception("Authentication failed.");
      }
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  await configureAmplify(); // Configure Amplify before running the app

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
    //  Debuging for caching
    // DefaultCacheManager().emptyCache();
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
        '/categoryInfo': (context) => const CategoryInfoPage(
              categoryTitle: '',
              listId: '',
            ),
        '/plantInfoFromCategory': (context) =>
            const PlantInfoFromCategoryPage(speciesObject: {}),
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
