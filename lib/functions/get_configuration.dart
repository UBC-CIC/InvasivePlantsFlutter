import 'package:flutter_dotenv/flutter_dotenv.dart';

// Get configuration values
Map<String, String> getConfiguration() {
  // Get secret name
  final apiBaseUrl = dotenv.env['BASE_API_URL'];
  final apiKey = dotenv.env['API_KEY'];
  final cognitoRegion = dotenv.env['COGNITO_REGION'];
  final cognitoPoolId = dotenv.env['COGNITO_POOL_ID'];
  final cognitoAppClientId = dotenv.env['COGNITO_APP_CLIENT_ID'];
  final plantnetAPIKey = dotenv.env['PLANTNET_API_KEY'];

  // Check for error
  if (apiBaseUrl == null ||
      apiKey == null ||
      cognitoRegion == null ||
      cognitoPoolId == null ||
      cognitoAppClientId == null ||
      plantnetAPIKey == null) {
    throw AssertionError('Some keys are not set.');
  }

  return {
    "apiBaseUrl": apiBaseUrl,
    "apiKey": apiKey,
    "cognitoRegion": cognitoRegion,
    "cognitoPoolId": cognitoPoolId,
    "cognitoAppClientId": cognitoAppClientId,
    "plantnetAPIKey": plantnetAPIKey
  };
}
