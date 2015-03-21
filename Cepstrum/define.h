//
//  define.h
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

static const int bufferSize = 1024;
// return max value for given values
#define max(a, b) (((a) > (b)) ? (a) : (b))
// return min value for given values
#define min(a, b) (((a) < (b)) ? (a) : (b))

#define PI 3.14159265358979323846

#define kOutputBus 0
#define kInputBus 1

// our default sample rate
#define SAMPLE_RATE 44100.00

#define kGraphWindowHeight 30
#define kGraphWindowWidth 300

#define kGraphBottom -50
#define kGraphTop 50

#define kGraphAudioMinX 0
#define kGraphAudioMaxX bufferSize
#define kGraphAudioMaxY 1
#define kGraphAudioMinY -1

#define kGraphFftMinX 0
#define kGraphFftMaxX bufferSize
#define kGraphFftMaxY 1
#define kGraphFftMinY -1

#define kGraphCepstrumMinX 0
#define kGraphCepstrumMaxX bufferSize
#define kGraphCepstrumMaxY 1
#define kGraphCepstrumMinY -1

//Tweaking the Grid Lines
#define kOffsetX 0
#define kStepX 10
#define kOffsetY 50
#define kStepY 1

//data point emphasis
#define kCircleRadius 3

#define cepstrumZoom 1

#define refreshRate 1

//display types
#define kAudio @"audio"
#define kAudioMod @"audioMod"
#define kSpectrum @"spectrum"
#define kSpectrumReal @"spectrumR"
#define kSpectrumImag @"spectrumI"
#define kCepstrum @"cepstrum"
#define kCepstrumReal @"cepstrumR"
#define kCepstrumImag @"cepstrumI"






