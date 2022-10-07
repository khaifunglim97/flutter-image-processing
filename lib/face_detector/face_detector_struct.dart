import 'dart:ffi';

class EyeCenter extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
}

class FaceRect extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
  @Int32()
  external int height;
  @Int32()
  external int width;
  external Pointer<EyeCenter> eyes;
  @Int32()
  external int eyesCount;
}

class FacesDetected extends Struct {
  external Pointer<FaceRect> faces;
  @Int32()
  external int count;
}

class DartEyeCenter {
  late int x;
  late int y;

  DartEyeCenter.fromEyeCenter(EyeCenter eyeCenter) {
    x = eyeCenter.x;
    y = eyeCenter.y;
  }
}

class DartFaceRect {
  late int x;
  late int y;
  late int height;
  late int width;
  late List<DartEyeCenter> eyes;
  late int eyesCount;

  DartFaceRect.fromFaceRect(FaceRect faceRect) {
    x = faceRect.x;
    y = faceRect.y;
    height = faceRect.height;
    width = faceRect.width;
    final dartEyes = <DartEyeCenter>[];
    for (int i = 0; i < faceRect.eyesCount; i++) {
      final eye = faceRect.eyes[i];
      dartEyes.add(DartEyeCenter.fromEyeCenter(eye));
    }
    eyes = dartEyes;
    eyesCount = faceRect.eyesCount;
  }
}

class DartFacesDetected {
  late List<DartFaceRect> faces;
  late int count;

  DartFacesDetected.fromFacesDetected(FacesDetected facesDetected) {
    final dartFaces = <DartFaceRect>[];
    for (int i = 0; i < facesDetected.count; i++) {
      final face = facesDetected.faces[i];
      dartFaces.add(DartFaceRect.fromFaceRect(face));
    }
    faces = dartFaces;
    count = facesDetected.count;
  }
}
