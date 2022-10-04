import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  List<CameraDescription>? _cameras;

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> initCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  }

  Future _processCameraImage(CameraImage camImage) async {

  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initCameras();
      final cameras = _cameras;
      if (cameras != null) {
        controller = CameraController(
            cameras[0],
            ResolutionPreset.high,
            enableAudio: false
        );
        controller?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
          controller?.startImageStream(_processCameraImage);
          setState(() {});
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                showInSnackBar('User denied camera access.');
                break;
              default:
                showInSnackBar('Handle other errors.');
                break;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camController = controller;
    if (camController == null || !camController.value.isInitialized) {
      return Container();
    }

    return MaterialApp(
      home: CameraPreview(camController),
    );
  }
}
