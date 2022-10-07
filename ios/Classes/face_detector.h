#ifndef FLUTTER_FACE_DETECTOR_H
#define FLUTTER_FACE_DETECTOR_H

typedef struct EyeCenter {
    int x;
    int y;
} EyeCenter;

typedef struct FaceRect {
    int x;
    int y;
	int height;
	int width;
	EyeCenter* eyes;
	int eyesCount;
} FaceRect;

typedef struct FacesDetected {
    FaceRect* faces;
    int count;
} FacesDetected;

#ifdef __cplusplus
extern "C" {
#endif

    int LoadHaarCascades(const char* face_cascade_name, const char* eyes_cascade_name);
    int DetectAndDisplay(unsigned char *byteData, int height, int width, FacesDetected* outFacesDetected);

#ifdef __cplusplus
}
#endif

#endif //FLUTTER_FACE_DETECTOR_H
