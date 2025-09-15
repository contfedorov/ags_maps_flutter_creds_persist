import 'dart:async';

import 'package:arcgis_maps/arcgis_maps.dart';

class TokenProvider implements ArcGISAuthenticationChallengeHandler {
  final OAuthUserConfiguration _oAuthUserConfiguration;

  TokenProvider({required OAuthUserConfiguration oAuthUserConfiguration})
      : _oAuthUserConfiguration = oAuthUserConfiguration {
    ArcGISEnvironment
        .authenticationManager.arcGISAuthenticationChallengeHandler = this;
  }

  Future<void> signOut() async {
    await Future.wait(
      ArcGISEnvironment.authenticationManager.arcGISCredentialStore
          .getCredentials()
          .whereType<OAuthUserCredential>()
          .map((credential) => credential.revokeToken()),
    );
    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll();
  }

  @override
  void handleArcGISAuthenticationChallenge(
      ArcGISAuthenticationChallenge challenge) async {
    try {
      // Initiate the sign in process to the OAuth server using the defined user configuration.
      final credential = await _getCredential();

      // Sign in was successful, so continue with the provided credential.
      challenge.continueWithCredential(credential);
    } on ArcGISException catch (error) {
      // Sign in was canceled, or there was some other error.
      // todo: handle other error types
      // Unhandled Exception: type 'PlatformException' is not a subtype of type 'ArcGISException?' in type cast
      final e = (error.wrappedException as ArcGISException?) ?? error;
      if (e.errorType == ArcGISExceptionType.commonUserCanceled) {
        challenge.cancel();
      } else {
        challenge.continueAndFail();
      }
    }
  }

  Future<OAuthUserCredential> _getCredential() async {
    final portalUri = _oAuthUserConfiguration.portalUri;

    OAuthUserCredential oauthCredential;
    final credential = _pickCredential(portalUri);

    if (credential != null) {
      oauthCredential = credential as OAuthUserCredential;
    } else {
      oauthCredential = await OAuthUserCredential.create(
          configuration: _oAuthUserConfiguration);
      ArcGISEnvironment.authenticationManager.arcGISCredentialStore
          .add(credential: oauthCredential);
    }

    return oauthCredential;
  }

  ArcGISCredential? _pickCredential(Uri portalUri) {
    return ArcGISEnvironment
        .authenticationManager.arcGISCredentialStore
        .getCredential(uri: portalUri);
  }
}
