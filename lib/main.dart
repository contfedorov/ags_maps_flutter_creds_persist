import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'token_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  ArcGISEnvironment.authenticationManager.arcGISCredentialStore =
  await ArcGISCredentialStore.initPersistentStore();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final tokenProvider = TokenProvider(
      oAuthUserConfiguration: OAuthUserConfiguration(
        portalUri: Uri.parse('https://www.arcgis.com'),
        clientId: dotenv.get('OAUTH_CLIENT_ID'),
        redirectUri: Uri.parse(dotenv.get('OAUTH_REDIRECT_URI')),
      )
  );

  final _mapViewController = ArcGISMapView.createController();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: ArcGISMapView(
          controllerProvider: () => _mapViewController,
          onMapViewReady: onMapViewReady,
        ),
      )
    );
  }

  void onMapViewReady() {
    // Create a map from a web map that has a secure layer (traffic).
    final portalItem = PortalItem.withPortalAndItemId(
      portal: Portal.arcGISOnline(connection: PortalConnection.authenticated),
      itemId: 'e5039444ef3c48b8a8fdc9227f9be7c1',
    );
    final map = ArcGISMap.withItem(portalItem);

    // Set the map to map view controller.
    _mapViewController.arcGISMap = map;
  }
}