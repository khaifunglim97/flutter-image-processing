import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_image_processing_method_channel.dart';

abstract class FlutterImageProcessingPlatform extends PlatformInterface {
  /// Constructs a FlutterImageProcessingPlatform.
  FlutterImageProcessingPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterImageProcessingPlatform _instance = MethodChannelFlutterImageProcessing();

  /// The default instance of [FlutterImageProcessingPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterImageProcessing].
  static FlutterImageProcessingPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterImageProcessingPlatform] when
  /// they register themselves.
  static set instance(FlutterImageProcessingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
