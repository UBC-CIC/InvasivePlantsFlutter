const amplifyconfig = ''' {
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
            "PoolId": "ca-central-1_13CU9ay4Z",                                           
            "AppClientId": "29h6fghh9400hupk1osffdn8qe",                          
            "Region": "ca-central-1"                                              
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
