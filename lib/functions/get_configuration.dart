// Get configuration values
Map<String, String> getConfiguration() {
  // Get secret name
  const apiBaseUrl = String.fromEnvironment('BASE_API_URL');
  const apiKey = String.fromEnvironment('API_KEY');
  const cognitoRegion = String.fromEnvironment('COGNITO_REGION');
  const cognitoPoolId = String.fromEnvironment('COGNITO_POOL_ID');
  const cognitoAppClientId = String.fromEnvironment('COGNITO_APP_CLIENT_ID');
  const plantnetAPIKey = String.fromEnvironment('PLANTNET_API_KEY');

  // Check for error
  if (apiBaseUrl.isEmpty ||
      apiKey.isEmpty ||
      cognitoRegion.isEmpty ||
      cognitoPoolId.isEmpty ||
      cognitoAppClientId.isEmpty ||
      plantnetAPIKey.isEmpty) {
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
