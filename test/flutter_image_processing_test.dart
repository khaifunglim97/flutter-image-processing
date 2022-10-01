import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_image_processing/flutter_image_processing.dart';
import 'package:flutter_image_processing/flutter_image_processing_platform_interface.dart';
import 'package:flutter_image_processing/flutter_image_processing_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterImageProcessingPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterImageProcessingPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterImageProcessingPlatform initialPlatform = FlutterImageProcessingPlatform.instance;

  test('$MethodChannelFlutterImageProcessing is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterImageProcessing>());
  });

  test('getPlatformVersion', () async {
    FlutterImageProcessing flutterImageProcessingPlugin = FlutterImageProcessing();
    MockFlutterImageProcessingPlatform fakePlatform = MockFlutterImageProcessingPlatform();
    FlutterImageProcessingPlatform.instance = fakePlatform;
  
    expect(await flutterImageProcessingPlugin.getPlatformVersion(), '42');
  });
}
