// Get configuration values
Map<String, String> getConfiguration(){
  // Get secret name
  const apiBaseUrl = String.fromEnvironment('BASE_API_URL');
  const apiKey = String.fromEnvironment('API_KEY');
  const cognitoRegion = String.fromEnvironment('COGNITO_REGION');
  const cognitoPoolId = String.fromEnvironment('COGNITO_POOL_ID');
  const cognitAppClientId = String.fromEnvironment('COGNITO_APP_CLIENT_ID');
  
  // Check for error
  if (apiBaseUrl.isEmpty || 
      apiKey.isEmpty || 
      cognitoRegion.isEmpty ||
      cognitoPoolId.isEmpty ||
      cognitAppClientId.isEmpty) {
    throw AssertionError('Some keys are not set.');
  }

  return {  "apiBaseUrl": apiBaseUrl, 
            "apiKey":apiKey, 
            "cognitoRegion": cognitoRegion, 
            "cognitoPoolId": cognitoPoolId, 
            "cognitAppClientId": cognitAppClientId};
}