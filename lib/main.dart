import 'dart:io';
import 'content_aware_scaler.dart';
import 'energy_fuctions.dart';
import 'package:flutter/material.dart';
import 'package:seam_carver/widgets.dart';
import 'package:image/image.dart' as formattedImage;

import 'image_editor.dart';
import 'image_selection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() {
  init().then((files) {
    runApp(MyApp(files));
  });
}

Future<Map<String, File>> init() async {
  Map<String, File> testFiles = new Map();
  testFiles["Ocean Waves"] = await getImageFileFromAssets("hjocean.png");
  testFiles["Group Picture"] = await getImageFileFromAssets("spaced_people.png");
  testFiles["Dolphin"] = await getImageFileFromAssets("dolphin.jpeg");
  testFiles["Room Interior"] = await getImageFileFromAssets("interior.jpeg");
  testFiles["Boat and City"] = await getImageFileFromAssets("boat_river.jpeg");
  testFiles["Catalina"] = await getImageFileFromAssets("catalina.jpeg");
  return testFiles;
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}


class MyApp extends StatelessWidget {

  Map<String, File> testFiles;

  MyApp(this.testFiles);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seam Carver',
      theme: ThemeData(primaryColor: Colors.blue, brightness: Brightness.dark, accentColor: Colors.lightBlue),
      //home: ImageEditor("/Users/srujan_mupparapu/Desktop/CAS Media/spaced_people.png"),
      home: ImageSelection(testFiles),
      debugShowCheckedModeBanner: false,
    );
  }

}

