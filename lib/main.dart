import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

void main() {
  ArcGISEnvironment.apiKey = "";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          controllerProvider: () => ArcGISMapView.createController()
            ..arcGISMap = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISImagery),
        ),
      )
    );
  }
}