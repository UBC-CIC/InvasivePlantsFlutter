const amplifyconfig = ''' {
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "[COGNITO IDENTITY POOL ID]",
              "Region": "[REGION]"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "[COGNITO USER POOL ID]",
            "AppClientId": "[COGNITO USER POOL APP CLIENT ID]",
            "Region": "[REGION]"
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
