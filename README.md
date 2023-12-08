# InvasivePlantsFlutter
## Setup
Environment variable, create this file `api-keys.dev.json` at main root.

To run the app, use the command below,
``` bash
flutter run --dart-define-from-file=api-keys.dev.json
```

Content for `api-keys.dev.json`
```
{
    "BASE_API_URL": "",
    "API_KEY": "",
    "COGNITO_REGION": "",
    "COGNITO_POOL_ID": "",
    "COGNITO_APP_CLIENT_ID":""
}
```

### VSCode Setup for debugging
Create a file call folowing `.vscode/launch.json` with the following value.
```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch",
            "request": "launch",
            "type": "dart",
            "program": "flutter_app/lib/main.dart",
            "args": [
              "--dart-define-from-file",
              "api-keys.dev.json"
            ]
        }
    ]
}
```