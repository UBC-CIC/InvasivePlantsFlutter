// ignore_for_file: deprecated_member_use

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class Credentials {
  final String accessKeyId;
  final String secretAccessKey;
  final String? sessionToken;

  Credentials({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.sessionToken,
  });
}

Future<Credentials> getCredentials() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final result = await cognitoPlugin.fetchAuthSession();
    final accessKeyId = result.credentials!.accessKeyId;
    final secretAccessKey = result.credentials!.secretAccessKey;
    final sessionToken = result.credentials!.sessionToken;

    return Credentials(
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      sessionToken: sessionToken,
    );
  } on AuthException catch (e) {
    print('Error retrieving auth session: ${e.message}');
    throw e;
  }
}
