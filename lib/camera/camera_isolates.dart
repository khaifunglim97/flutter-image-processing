// https://github.com/dart-lang/samples/blob/master/isolates/bin/send_and_receive.dart
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../flutter_image_processing.dart';

// TODO: isolates calling native might have memory leaks (must be tested)
class CameraIsolates {
  static const keyConvertResult = "outBgra";

  static Future<Map<String, dynamic>> spawnAndConvertImage(CameraImage image) async {
    final p = ReceivePort();
    await Isolate.spawn(_convertCamImageToBgra, [
      p.sendPort,
      image
    ]);
    return (await p.first) as Map<String, dynamic>;
  }

  static void _convertCamImageToBgra(List<dynamic> args) async {
    SendPort responsePort = args[0];
    CameraImage image = args[1];
    Uint8List? outBgra;
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        outBgra = FlutterImageProcessing.cameraBindings
            .convertAndroidCamImage2Bgra(
            image.planes[0].bytes,
            image.planes[1].bytes,
            image.planes[2].bytes,
            image.planes[0].bytesPerRow,
            image.planes[0].bytesPerPixel!,
            image.planes[1].bytesPerRow,
            image.planes[1].bytesPerPixel!,
            image.width,
            image.height
        );
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        outBgra = image.planes[0].bytes;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error (convertCamImageToBgra): ${e.toString()}");
      }
    }

    Map result = <String, dynamic>{};
    result[keyConvertResult] = outBgra;
    Isolate.exit(responsePort, result);
  }
}
