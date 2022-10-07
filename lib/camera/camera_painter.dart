import 'package:flutter/material.dart';

import '../face_detector/face_detector_struct.dart';

// https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example/lib/vision_detector_views
class CameraPainter extends CustomPainter {
  CameraPainter(this.facesDetected, this.absoluteImageSize);

  final DartFacesDetected facesDetected;
  final Size absoluteImageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (final DartFaceRect face in facesDetected.faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          CoordinatesTranslator.translateX(
              face.x.toDouble(), size, absoluteImageSize),
          CoordinatesTranslator.translateY(
              face.y.toDouble(), size, absoluteImageSize),
          CoordinatesTranslator.translateX(
              (face.x + face.width).toDouble(), size, absoluteImageSize),
          CoordinatesTranslator.translateY(
              (face.y + face.height).toDouble(), size, absoluteImageSize),
        ),
        paint,
      );

      for (final DartEyeCenter eyeCenter in face.eyes) {
        canvas.drawCircle(
            Offset(
                CoordinatesTranslator.translateX(
                    eyeCenter.x.toDouble(), size, absoluteImageSize),
                CoordinatesTranslator.translateY(
                    eyeCenter.y.toDouble(), size, absoluteImageSize)
            ),
            10,
            paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(CameraPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.facesDetected != facesDetected;
  }
}

class CoordinatesTranslator {
  static double translateX(
      double x, Size size, Size absoluteImageSize) {
    return x * size.width / absoluteImageSize.width;
  }

  static double translateY(
      double y, Size size, Size absoluteImageSize) {
    return y * size.height / absoluteImageSize.height;
  }
}
