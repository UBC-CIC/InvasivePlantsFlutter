import 'dart:convert';

import 'package:flutter/material.dart';
import './pages/log_in_page.dart';
import './pages/sign_up_page.dart';
import 'package:provider/provider.dart';
import './pages/home_page.dart';
import './pages/plant_list_page.dart';
import './pages/alternative_plant_page.dart';
import './pages/camera_page.dart';
import './pages/plant_identification_page.dart';
import './pages/saved_lists_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import './configuration/AmplifyConfig.dart';
import './functions/get_configuration.dart';
import './notifiers/plant_details_notifier.dart';
import './notifiers/user_lists_notifier.dart';
import './global/GlobalVariables.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/services.dart'; // Import SystemChrome class

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // Lock to portrait mode

  Future<void> configureAmplify() async {
    try {
      await dotenv.load();
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

  FlutterNativeSplash.remove();
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            primary: AppColors.primaryColor,
            secondary: AppColors.secondaryColor),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomePage(),
        '/categoryInfo': (context) => const PlantListPage(
              categoryTitle: '',
              listId: '',
            ),
        '/plantInfoFromCategory': (context) =>
            const AlternativePlantPage(speciesObject: {}),
        '/camera': (context) => const CameraPage(),
        '/plantIdentification': (context) => const PlantIdentificationPage(
              imagePath: '',
            ),
        '/myPlants': (context) => const SavedListsPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LogInPage(),
      },
    );
  }
}
