import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_isolates.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
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

  bool isBusy = false;
  Future _processCameraImage(CameraImage camImage) async {
    if (isBusy) return;

    isBusy = true;
    await CameraIsolates.spawnAndConvertImage(camImage);

    isBusy = false;
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

    return CameraPreview(camController);
  }
}
