//
//  AudioProcessor.h
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Accelerate/Accelerate.h"
#import "define.h"


@class AudioProcessor;

@protocol AudioProcessorDelegate <NSObject>

-(void) audioProcessor:(AudioProcessor *)audioProcessor hasDataReceived:(float *)buffer withBufferSize:(UInt32)bufferSize withType:(NSString *)type withWindow:(int)window withTitle:(NSString*)title;

@end


@interface AudioProcessor : NSObject
{
    // Audio unit
    AudioComponentInstance audioUnit;
    
    // Audio buffers
	AudioBuffer audioBuffer;
    
    FFTSetup setupFFT;
    
    COMPLEX_SPLIT C;
    COMPLEX_SPLIT Cm;
    COMPLEX_SPLIT I;
    COMPLEX_SPLIT Im;

    float spectrumBuffer[bufferSize];
    float spectrumBufferReal[bufferSize];
    float spectrumBufferIma[bufferSize];
    
    float spectrumBufferPower[bufferSize];
    float spectrumBufferPhase[bufferSize];
    
    float spectrumModBufferReal[bufferSize];
    float spectrumModBufferIma[bufferSize];
    
    float spectrumModBufferPower[bufferSize];
    float spectrumModBufferPhase[bufferSize];
    
    float cepstrumBuffer[bufferSize];
    float cepstrumBufferReal[bufferSize];
    float cepstrumBufferIma[bufferSize];
    
    float spectrumSecondInput[bufferSize];
    float outputBufferFloat[bufferSize];
    
    SInt16 outputBuffer[bufferSize];
    float secondInput[bufferSize];
    
    float inputBufferFloat[bufferSize];
    float inputModBufferFloat[bufferSize];
    
    int lifter;
    int delay;
    int note1;
    int note2;
    int note3;
    int note4;
    BOOL isModAudio;
}
@property (nonatomic,assign) id<AudioProcessorDelegate> audioProcessorDelegate;

@property (readonly) AudioBuffer audioBuffer;
@property (readonly) AudioComponentInstance audioUnit;
@property (nonatomic) int lifter;
@property (nonatomic) int delay;
@property (nonatomic) BOOL isModAudio;


@property (nonatomic) int note1;
@property (nonatomic) int note2;
@property (nonatomic) int note3;
@property (nonatomic) int note4;




-(AudioProcessor*)initWithAudioProcessorDelegate:(id<AudioProcessorDelegate>)audioProcessorDelegate;

-(void)initializeAudio;
-(void)processBuffer: (AudioBufferList*) audioBufferList :(UInt32) inNumberFrames;

// control object
-(void)start;
-(void)stop;

@end
