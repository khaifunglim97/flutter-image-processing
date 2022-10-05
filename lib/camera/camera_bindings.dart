import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../flutter_image_processing.dart';
import 'camera_struct.dart';

class CameraBindings {
  final Pointer<T> Function<T extends NativeType>(String symbolName)
    _lookup;

  CameraBindings(DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  CameraBindings.fromLookup(
      Pointer<T> Function<T extends NativeType>(String symbolName)
      lookup)
      : _lookup = lookup;

  Uint8List convertAndroidCamImage2Bgra(
      Uint8List plane0Bytes,
      Uint8List plane1Bytes,
      Uint8List plane2Bytes,
      int yBytesPerRow,
      int yBytesPerPixel,
      int uvBytesPerRow,
      int uvBytesPerPixel,
      int width,
      int height
  ) {
    Pointer<AndroidCamImage> ptr = malloc<AndroidCamImage>();
    Pointer<Uint32> outBytes = malloc.allocate(sizeOf<Uint32>() * width * height);
    Pointer<Uint8> plane0Ptr = plane0Bytes.allocatePointer();
    Pointer<Uint8> plane1Ptr = plane1Bytes.allocatePointer();
    Pointer<Uint8> plane2Ptr = plane2Bytes.allocatePointer();

    try {
      ptr.ref.outImageBgr = outBytes;
      ptr.ref.plane0 = plane0Ptr;
      ptr.ref.plane1 = plane1Ptr;
      ptr.ref.plane2 = plane2Ptr;
      ptr.ref.yRowStride = yBytesPerRow;
      ptr.ref.yPixelStride = yBytesPerPixel;
      ptr.ref.uvRowStride = uvBytesPerRow;
      ptr.ref.uvPixelStride = uvBytesPerPixel;
      ptr.ref.width = width;
      ptr.ref.height = height;

      final res = _convertAndroidCamImage2Bgra(ptr);
      if (res != 0) throw Exception("CamBindings: convertAndroidCamImage2Bgra");
      
      return Uint8List.fromList(
          ptr.ref.outImageBgr.asTypedList(width * height).buffer.asUint8List()
      );
    } finally {
      malloc.free(plane0Ptr);
      malloc.free(plane1Ptr);
      malloc.free(plane2Ptr);
      malloc.free(outBytes);
      malloc.free(ptr);
    }
  }

  late final _convertAndroidCamImage2BgraPtr = _lookup<
      NativeFunction<Int32 Function(Pointer<AndroidCamImage>)>>('ConvertAndroidCamImage2Bgra');
  late final _convertAndroidCamImage2Bgra = _convertAndroidCamImage2BgraPtr
      .asFunction<int Function(Pointer<AndroidCamImage>)>();
}
