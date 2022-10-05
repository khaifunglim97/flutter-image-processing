import 'dart:ffi';

class AndroidCamImage extends Struct {
  external Pointer<Uint32> outImageBgr;
  external Pointer<Uint8> plane0;
  external Pointer<Uint8> plane1;
  external Pointer<Uint8> plane2;
  @Int32()
  external int yRowStride;
  @Int32()
  external int yPixelStride;
  @Int32()
  external int uvRowStride;
  @Int32()
  external int uvPixelStride;
  @Int32()
  external int width;
  @Int32()
  external int height;
}
