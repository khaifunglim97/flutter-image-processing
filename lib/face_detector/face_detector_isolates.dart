// https://github.com/dart-lang/samples/blob/master/isolates/bin/send_and_receive.dart
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../flutter_image_processing.dart';
import 'face_detector_struct.dart';

// TODO: isolates calling native might have memory leaks (must be tested)
class FaceDetectorIsolates {
  static const keyLoadHaarCascades = "loadHaarCascadeStatus";
  static const keyDetect = "detectAndDisplay";

  static Future<Map<String, dynamic>> spawnAndLoadHaarCascades(
      String eyeFilePath,
      String faceFilePath,
  ) async {
    final p = ReceivePort();
    await Isolate.spawn(_loadHaarCascades, [
      p.sendPort,
      eyeFilePath,
      faceFilePath
    ]);
    return (await p.first) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> spawnAndDetect(
      Uint8List bytes,
      int height,
      int width,
  ) async {
    final p = ReceivePort();
    await Isolate.spawn(_detect, [
      p.sendPort,
      bytes,
      height,
      width
    ]);
    return (await p.first) as Map<String, dynamic>;
  }

  static void _loadHaarCascades(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String eyeFilePath = args[1];
    String faceFilePath = args[2];
    bool success = false;
    try {
      await FlutterImageProcessing.faceDetectorBindings.loadHaarCascade(eyeFilePath, faceFilePath);
      success = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error (loadHaarCascades): ${e.toString()}");
      }
    }

    Map result = <String, dynamic>{};
    result[keyLoadHaarCascades] = success;
    Isolate.exit(responsePort, result);
  }

  static void _detect(List<dynamic> args) async {
    SendPort responsePort = args[0];
    Uint8List bytes = args[1];
    int height = args[2];
    int width = args[3];

    DartFacesDetected? detected;
    try {
      detected = FlutterImageProcessing.faceDetectorBindings
          .detectAndDisplay(bytes, height, width);
    } catch (e) {
      if (kDebugMode) {
        print("Error (detect): ${e.toString()}");
      }
    }

    Map result = <String, dynamic>{};
    result[keyDetect] = detected;
    Isolate.exit(responsePort, result);
  }
}
