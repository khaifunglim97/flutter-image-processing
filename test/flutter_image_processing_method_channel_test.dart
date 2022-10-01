import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_image_processing/flutter_image_processing_method_channel.dart';

void main() {
  MethodChannelFlutterImageProcessing platform = MethodChannelFlutterImageProcessing();
  const MethodChannel channel = MethodChannel('flutter_image_processing');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
