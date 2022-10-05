#ifndef FLUTTER_CONVERTER_H
#define FLUTTER_CONVERTER_H

#include <stdint.h>
#include <stdlib.h>

typedef struct AndroidCamImage {
	uint32_t*   outImageBgr;
	uint8_t*    plane0;
	uint8_t*    plane1;
	uint8_t*    plane2;
	int         yRowStride;
	int         yPixelStride;
	int         uvRowStride;
	int         uvPixelStride;
	int         width;
	int         height;
} AndroidCamImage;

int ConvertAndroidCamImage2Bgra(AndroidCamImage const * srcAndroidCamImg);

#endif //FLUTTER_CONVERTER_H
