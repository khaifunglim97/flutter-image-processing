
import 'flutter_image_processing_platform_interface.dart';

class FlutterImageProcessing {
  Future<String?> getPlatformVersion() {
    return FlutterImageProcessingPlatform.instance.getPlatformVersion();
  }
}
