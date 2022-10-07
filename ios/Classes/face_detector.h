#ifndef FLUTTER_FACE_DETECTOR_H
#define FLUTTER_FACE_DETECTOR_H

typedef struct FaceRect {
    int x;
    int y;
	int height;
	int width;
} FaceRect;

typedef struct FacesDetected {
    FaceRect* faces;
    int count;
} FacesDetected;

extern "C" {
    int LoadHaarCascades(const char* face_cascade_name, const char* eyes_cascade_name);
    int DetectAndDisplay(unsigned char *byteData, int height, int width, FacesDetected* outFacesDetected);
}

#endif //FLUTTER_FACE_DETECTOR_H
