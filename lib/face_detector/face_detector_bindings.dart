import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../flutter_image_processing.dart';
import 'face_detector_struct.dart';

class FaceDetectorBindings {
  // https://stackoverflow.com/a/71186701
  static Future<File> loadHaarCascadeFromAssets(String filename) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filePath = "$tempPath/$filename";
    final file = File(filePath);
    if (!file.existsSync()) {
      final cascadeXml = await rootBundle.loadString(
          'packages/flutter_image_processing/assets/$filename');
      final document = XmlDocument.parse(cascadeXml);
      return compute(_writeXmlFile, [filePath, document.toString()]);
    }
    return file;
  }

  static Future<File> _writeXmlFile(List<String> args) async {
    final filePath = args[0];
    final xmlString = args[1];
    return File(filePath)
        .writeAsString(xmlString, mode: FileMode.write, flush: true);
  }

  final Pointer<T> Function<T extends NativeType>(String symbolName)
    _lookup;

  FaceDetectorBindings(DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  FaceDetectorBindings.fromLookup(
      Pointer<T> Function<T extends NativeType>(String symbolName)
      lookup)
      : _lookup = lookup;

  Future<void> loadHaarCascade(String eyeFilePath, String faceFilePath) async {
    final eyePath = eyeFilePath.toNativeUtf8();
    final facePath = faceFilePath.toNativeUtf8();

    try {
      int res = _loadHaarCascades(facePath, eyePath);
      if (res == 1) throw Exception("Failed to load FaceCascade");
      if (res == 2) throw Exception("Failed to load EyeCascade");
      if (res != 0) throw Exception("Error loading HaarCascades");
    } finally {
      malloc.free(eyePath);
      malloc.free(facePath);
    }

    return;
  }

  late final _loadHaarCascadesPtr = _lookup<
      NativeFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>)>>('LoadHaarCascades');
  late final _loadHaarCascades = _loadHaarCascadesPtr
      .asFunction<int Function(Pointer<Utf8>, Pointer<Utf8>)>();

  DartFacesDetected detectAndDisplay(Uint8List bytes, int height, int width) {
    Pointer<Uint8> ptr = bytes.allocatePointer();
    Pointer<FacesDetected> facesDetected = malloc<FacesDetected>();
    try {
      int res = _detectAndDisplay(ptr, height, width, facesDetected);
      if (res != 0) throw Exception("Error in DetectAndDisplay");

      return DartFacesDetected.fromFacesDetected(facesDetected.ref);
    } finally {
      malloc.free(ptr);
      for (int i=0; i < facesDetected.ref.count; i++) {
        malloc.free(facesDetected.ref.faces[i].eyes);
      }
      malloc.free(facesDetected.ref.faces);
      malloc.free(facesDetected);
    }
  }

  late final _detectAndDisplayPtr = _lookup<
      NativeFunction<Int32 Function(Pointer<Uint8>, Int32, Int32, Pointer<FacesDetected>)>>('DetectAndDisplay');
  late final _detectAndDisplay = _detectAndDisplayPtr
      .asFunction<int Function(Pointer<Uint8>, int, int, Pointer<FacesDetected>)>();
}
