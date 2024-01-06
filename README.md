# InvasiveID

InvasiveID is a mobile app that allows users to identify invasive plants based on their region and suggests alternative non-invasive plants to plant instead. Authorized users can also create their own lists of plants. For more information, please visit the [CIC Website](https://cic.ubc.ca/).

|Index| Description|
|:----------------|:-----------|
| [Deployment](#deployment-guide)         |    Learn how to deploy this project yourself |
| [User Guide](#user-guide)         |    Learn how to use this application |
| [Directories](#directories)                             | General project directory structure
| [Changelog](#changelog)         |    Any changes post publish |
| [Credits](#credits)         |    Meet the team behind the solution |
| [License](#license)      |     License details     |


# Deployment Guide

To deploy this solution, please follow our [Deployment Guide](docs/DeploymentGuide.md).

# User Guide

For instructions on how to use the mobile app, refer to the [User Guide](docs/UserGuide.md).

# Directories

```
├── android
├── assets
│   ├── images
│       ├── sources.md
│   └── screenshots
├── docs
├── ios
├── lib
│   ├── configuration
│   ├── functions
│   ├── global
│   ├── notifiers
│   ├── pages
│   └── main.dart
├── linux
├── macos
├── test
├── web
├── windows
├── .metadata
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```
1. `/android`: Contains the Android platform-specific code and configurations.
2. `/assets`: Holds the static files.
   - `/images`: The images used in the app.
     - `sources.md`: Links to the external files/images used in the app.
   - `/screenshots`: Screenshots of the main pages of the app.
   
3. `/docs`: Contains the documentation for the app - changelog, deployment guide, and user guide.
4. `/ios`: Contains iOS platform-specific code and configurations.
5. `/lib`: Houses the main source code for the Flutter app, organized into subdirectories.
    - `/configuration`: Holds configuration-related code.
    - `/functions`: Contains reusable functions or utility code.
     - `/global`: Stores global variables/constants.
     - `/notifiers`: Holds classes responsible for state management using providers or notifiers.
     - `/pages`: Contains different app screens or UI components.
     - `main.dart`: The entry point for the Flutter app, where execution begins.
6. `/linux`, `/macos`, `/web`, `/windows`: These directories hold platform-specific code for Linux, macOS, web, and Windows, respectively.
7. `/test`: Contains test-related files for automated testing.
8. `.metadata`: Internal metadata related to the Flutter project.
9.  `analysis_options.yaml`: Configuration file for static analysis tools like Dart analyzer.
10. `pubspec.lock`: Lock file specifying exact versions of dependencies used in the project.
11. `pubspec.yaml`: Project configuration file specifying dependencies, metadata, and more for the Flutter app.

# Changelog

View the changelog [here](/docs/Changelog.md).

# Credits

This application was architected and developed by Visal Saosuo, Julia You, and Yuheng Zhang, with project assistance from Franklin Ma. A special thanks to the UBC Cloud Innovation Centre Technical and Project Management teams for their guidance and support.

# License

This project is distributed under the [MIT License](./LICENSE).

Licenses of libraries and tools used by the system are listed below:

[MIT License](https://opensource.org/license/mit/)

- For cupertino_icons, permission_handler, provider, flutter_cache_manager, geolocator, geocoding, and flutter_launcher_icons

[BSD 3-clause](https://opensource.org/license/bsd-3-clause/)

- For camera, image_picker, path_provider, shared_preferences, http, url_launcher, http_parser,  and flutter_lints

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)

- For image_picker, amplify_flutter, and amplify_auth_cognito