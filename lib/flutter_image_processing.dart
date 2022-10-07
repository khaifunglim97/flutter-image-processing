import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'camera/camera_bindings.dart';
import 'face_detector/face_detector_bindings.dart';
import 'flutter_image_processing_platform_interface.dart';

final DynamicLibrary nativeFlutterImageProcessingLib = Platform.isAndroid
    ? DynamicLibrary.open('libflutter_image_processing.so')
    : DynamicLibrary.process();

//https://groups.google.com/g/flutter-dev/c/LLWPwBJLizc/m/yOs6kXuKAQAJ
extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Uint8> allocatePointer() {
    final blob = calloc<Uint8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}

class FlutterImageProcessing {
  Future<String?> getPlatformVersion() {
    return FlutterImageProcessingPlatform.instance.getPlatformVersion();
  }

  static final cameraBindings = CameraBindings(nativeFlutterImageProcessingLib);
  static final faceDetectorBindings = FaceDetectorBindings(nativeFlutterImageProcessingLib);
}
