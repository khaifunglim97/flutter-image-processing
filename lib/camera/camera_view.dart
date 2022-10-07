import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_processor.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  CameraImage? cameraImage;

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> initCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  }

  Future _processCameraImage(CameraImage camImage) async {
    if (!mounted) return;
    setState(() {
      cameraImage = camImage;
    });
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
        try {
          await controller?.initialize();
          controller?.startImageStream(_processCameraImage);
          setState(() {});
        } catch (e) {
          if (!mounted) {
            return;
          }
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
        }
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
    final camImg = cameraImage;
    if (camController == null
        || !camController.value.isInitialized
        || camImg == null) {
      return Scaffold(
          body: Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator(),),
          )
      );
    }

    // TODO: find a fix for scaffold white space if body is CameraPreview
    return CameraPreview(
      camController,
      child: CameraProcessor(
        image: camImg,
      ),
    );
  }
}
