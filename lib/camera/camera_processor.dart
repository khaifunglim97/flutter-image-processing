import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../face_detector/face_detector_bindings.dart';
import '../face_detector/face_detector_isolates.dart';
import '../face_detector/face_detector_struct.dart';
import 'camera_isolates.dart';
import 'camera_painter.dart';

class CameraProcessor extends StatefulWidget {
  final CameraImage image;
  const CameraProcessor(
      {Key? key, required this.image})
      : super(key: key);

  @override
  State<CameraProcessor> createState() => _CameraProcessorState();
}

class _CameraProcessorState extends State<CameraProcessor> {
  bool _modelsLoaded = false;
  CustomPaint? customPaint;

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> initHaarCascades() async {
    String eyeCascadeName = "haarcascade_eye_tree_eyeglasses.xml";
    String faceCascadeName = "haarcascade_frontalface_alt.xml";
    try {
      final eyeFile = await FaceDetectorBindings
          .loadHaarCascadeFromAssets(eyeCascadeName);
      final faceFile = await FaceDetectorBindings
          .loadHaarCascadeFromAssets(faceCascadeName);
      final resLoadCascades = await FaceDetectorIsolates
          .spawnAndLoadHaarCascades(eyeFile.path, faceFile.path);
      _modelsLoaded = resLoadCascades[FaceDetectorIsolates.keyLoadHaarCascades];
      if(!_modelsLoaded) {
        throw Exception("spawnAndLoadHaarCascades failed");
      }
    } catch (e) {
      showInSnackBar('Error (initHaarCascades): ${e.toString()}.');
    }
  }

  bool isBusy = false;
  Future _processCameraImage(CameraImage camImage) async {
    if (isBusy) return;

    isBusy = true;
    final resConvert = await CameraIsolates.spawnAndConvertImage(camImage);
    Uint8List? rgbaBytes = resConvert[CameraIsolates.keyConvertResult];

    if (_modelsLoaded && rgbaBytes != null) {
      final resDetect = await FaceDetectorIsolates
          .spawnAndDetect(rgbaBytes, camImage.width, camImage.height);
      DartFacesDetected? detected = resDetect[FaceDetectorIsolates.keyDetect];
      if (detected != null && detected.count > 0) {
        if (!mounted) return;
        setState(() {
          customPaint = CustomPaint(
              size: Size.infinite,
              painter: CameraPainter(
                  detected,
                  Size(camImage.height.toDouble(), camImage.width.toDouble())
              )
          );
        });
      } else {
        if (!mounted) return;
        setState(() {
          customPaint = null;
        });
      }
    }

    isBusy = false;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initHaarCascades();
    });
  }

  @override
  Widget build(BuildContext context) {
    _processCameraImage(widget.image);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          if (customPaint != null) customPaint!
        ],
      ),
    );
  }
}
