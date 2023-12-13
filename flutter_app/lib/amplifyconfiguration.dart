import 'lib.dart';

var configuration = getConfiguration();
String? poolId = configuration["cognitoPoolId"];
String? clientId = configuration["cognitAppClientId"];
String? region = configuration["cognitoRegion"];

var amplifyconfig = ''' {
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": $poolId,                                           
            "AppClientId": $clientId,                          
            "Region": $region                                              
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_PASSWORD_AUTH",                       
             "mandatorySignIn": "false"
          }
        }
      }
    }
  }
}''';
