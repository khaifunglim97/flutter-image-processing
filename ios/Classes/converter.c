#include "converter.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int clamp(int lower, int higher, int val){
    if(val < lower)
        return 0;
    else if(val > higher)
        return 255;
    else
        return val;
}

int getRotatedImageByteIndex(int x, int y, int rotatedImageWidth){
    return rotatedImageWidth*(y+1)-(x+1);
}

// https://gist.github.com/Alby-o/fe87e35bc21d534c8220aed7df028e03
// https://github.com/Hugand/camera_tutorial/
// TODO: Only works for android in portrait up mode
int ConvertAndroidCamImage2Bgra(
    AndroidCamImage const * srcAndroidCamImg
){
    int hexFF = 255;
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;
    int uvh, uvw, yIndex;

    int shift = (hexFF << 24);

    for(x = 0; x < srcAndroidCamImg->width; x++){
        uvw = ((int) floor(x/2));
        for(y = 0; y < srcAndroidCamImg->height; y++){
            uvh = ((int) floor(y/2));
            yIndex = (y * srcAndroidCamImg->yRowStride) + (x * srcAndroidCamImg->yPixelStride);

            yp = srcAndroidCamImg->plane0[yIndex];
            uvIndex = (uvh * srcAndroidCamImg->uvRowStride) + (uvw * srcAndroidCamImg->uvPixelStride);

            up = srcAndroidCamImg->plane1[uvIndex];
            vp = srcAndroidCamImg->plane2[uvIndex];
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);
            r = clamp(0, 255, rt);
            g = clamp(0, 255, gt);
            b = clamp(0, 255, bt);
            srcAndroidCamImg->outImageBgr[getRotatedImageByteIndex(y, x, srcAndroidCamImg->height)] = shift | (b << 16) | (g << 8) | r;
        }
    }

    return 0;
}
