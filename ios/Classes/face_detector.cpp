// https://docs.opencv.org/3.4/db/d28/tutorial_cascade_classifier.html
#include "face_detector.h"
#include <opencv2/objdetect.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <android/log.h>

// TODO: remove global variables and introduce proper memory management
cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;

// TODO: introduce unloading/delete cascade classifiers
int LoadHaarCascades(const char* face_cascade_name, const char* eyes_cascade_name)
{
    //-- 1. Load the cascades
    if(!face_cascade.load(face_cascade_name)) {
        // Error loading face cascade
        return 1;
    };

    if(!eyes_cascade.load(eyes_cascade_name)) {
        // Error loading eyes cascade
        return 2;
    };

    return 0;
}

/**
* Image can be resized, cropped, etc, to speed up detection.
* Only works for captured portrait images
*/
int DetectAndDisplay(
    unsigned char *byteData,
    int height,
    int width,
    FacesDetected* outFacesDetected
)
{
    cv::Mat frame, frame_gray;
    frame = cv::Mat(height, width, CV_8UC4, byteData);
    if (frame.empty()) {
        return -1;
    }
    cv::cvtColor( frame, frame_gray, cv::COLOR_BGRA2GRAY );
    cv::equalizeHist( frame_gray, frame_gray );
//    -- Detect faces
    std::vector<cv::Rect> faces;
    face_cascade.detectMultiScale( frame_gray, faces );
    FaceRect* facesDetected = (FaceRect*) malloc(faces.size() * sizeof(*facesDetected));
    outFacesDetected->count = faces.size();
    for ( size_t i = 0; i < faces.size(); i++ )
    {
        facesDetected[i] = (FaceRect) { faces[i].x, faces[i].y, faces[i].height, faces[i].width };
        cv::Mat faceROI = frame_gray( faces[i] );
        //-- In each face, detect eyes
        std::vector<cv::Rect> eyes;
        eyes_cascade.detectMultiScale( faceROI, eyes );
        for ( size_t j = 0; j < eyes.size(); j++ )
        {
            cv::Point eye_center( faces[i].x + eyes[j].x + eyes[j].width/2, faces[i].y + eyes[j].y + eyes[j].height/2 );
        }
    }
    outFacesDetected->faces = facesDetected;
    return 0;
}
