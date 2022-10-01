import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_image_processing_platform_interface.dart';

/// An implementation of [FlutterImageProcessingPlatform] that uses method channels.
class MethodChannelFlutterImageProcessing extends FlutterImageProcessingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_image_processing');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
