import 'dart:ffi';

class FaceRect extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
  @Int32()
  external int height;
  @Int32()
  external int width;
}

class FacesDetected extends Struct {
  external Pointer<FaceRect> faces;
  @Int32()
  external int count;
}

class DartFaceRect {
  late int x;
  late int y;
  late int height;
  late int width;

  DartFaceRect.fromFaceRect(FaceRect faceRect) {
    x = faceRect.x;
    y = faceRect.y;
    height = faceRect.height;
    width = faceRect.width;
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
