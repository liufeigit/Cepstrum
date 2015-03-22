//
//  AudioProcessor.m
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

#import "AudioProcessor.h"



const double two_pi = 2. * M_PI;

#pragma mark Recording callback

static OSStatus recordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp,  UInt32 inBusNumber,  UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = audioProcessor.audioBuffer;
    
    // a variable where we check the status
    OSStatus status;
    
    // render input and check for error
    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    
	// process the bufferlist in the audio processor
    [audioProcessor processBuffer:&bufferList :inNumberFrames];
	
    // clean up the buffer put value to 0
	//free(bufferList.mBuffers[0].mData);
	
    return noErr;
}

#pragma mark Playback callback

static OSStatus playbackCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags,  const AudioTimeStamp *inTimeStamp,  UInt32 inBusNumber,  UInt32 inNumberFrames, AudioBufferList *ioData) {    

    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
    
    // iterate over incoming stream an copy to output stream
	for (int i=0; i < ioData->mNumberBuffers; i++) { 
		AudioBuffer buffer = ioData->mBuffers[i];
		
        // find minimum size
		UInt32 size = min(buffer.mDataByteSize, [audioProcessor audioBuffer].mDataByteSize);
        
        // copy buffer to audio buffer which gets played after function return
		memcpy(buffer.mData, [audioProcessor audioBuffer].mData, size);
        
        // set data size
		buffer.mDataByteSize = size; 
    }
    return noErr;
}

#pragma mark objective-c class

@implementation AudioProcessor
@synthesize audioUnit, audioBuffer, lifter, delay, note1, note2, note3, note4, isModAudio;

-(AudioProcessor*)initWithAudioProcessorDelegate:(id<AudioProcessorDelegate>)audioProcessorDelegate {
    self = [super init];
    if (self) {
        lifter = bufferSize;
        isModAudio = FALSE;
        self.audioProcessorDelegate = audioProcessorDelegate;
        //init the table with space memory -> got a big increase in memory thus a warning although I free the tables
        I.realp = (float *) malloc(bufferSize * sizeof(float));
        I.imagp = (float *) malloc(bufferSize * sizeof(float));
        Im.realp = (float *) malloc(bufferSize * sizeof(float));
        Im.imagp = (float *) malloc(bufferSize * sizeof(float));
        C.realp = (float *) malloc(bufferSize * sizeof(float));
        C.imagp = (float *) malloc(bufferSize * sizeof(float));
        Cm.realp = (float *) malloc(bufferSize * sizeof(float));
        Cm.imagp = (float *) malloc(bufferSize * sizeof(float));
        [self initializeAudio];
    }
    return self;
}
-(void)initializeAudio {
    OSStatus status;
	
	// We define the audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output; // we want to ouput
	desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
	desc.componentFlags = 0; // must be zero
	desc.componentFlagsMask = 0; // must be zero
	desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
	
	// find the AU component by description
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// create audio unit by component
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);

	
    // define that we want record io on the input bus
    UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Input, // scope to input
								  kInputBus, // select input bus (1)
								  &flag, // set flag
								  sizeof(flag));
	
	// define that we want play on io on the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Output, // scope to output
								  kOutputBus, // select output bus (0)
								  &flag, // set flag
								  sizeof(flag));
	
	/* 
     We need to specifie our format on which we want to work.
     We use Linear PCM cause its uncompressed and we work on raw data.
     for more informations check.
     
     We want 16 bits, 2 bytes per packet/frames at 44khz 
     */
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= SAMPLE_RATE;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
    
    
    
	// set the format on the output stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  kInputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
    
    
    // set the format on the input stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	
	
	
    /**
        We need to define a callback structure which holds
        a pointer to the recordingCallback and a reference to
        the audio processor object
     */
	AURenderCallbackStruct callbackStruct;
    
    // set recording callback
	callbackStruct.inputProc = recordingCallback; // recordingCallback pointer
	callbackStruct.inputProcRefCon = self;

    // set input callback to recording callback on the input bus
	status = AudioUnitSetProperty(audioUnit, 
                                  kAudioOutputUnitProperty_SetInputCallback, 
								  kAudioUnitScope_Global, 
								  kInputBus, 
								  &callbackStruct, 
								  sizeof(callbackStruct));
    
	
    /*
     We do the same on the output stream to hear what is coming
     from the input stream
     */
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = self;
    
    // set playbackCallback as callback on our renderer for the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	
    // reset flag to 0
	flag = 0;
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output, 
								  kInputBus,
								  &flag, 
								  sizeof(flag));
	

    /*
     we set the number of channels to mono and allocate our block size to
     2048 bytes.
    */
	audioBuffer.mNumberChannels = 1;
	audioBuffer.mDataByteSize = bufferSize * 2;
	audioBuffer.mData = malloc( bufferSize * 2 );
    
    float aBufferLength = bufferSize/SAMPLE_RATE;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                            sizeof(aBufferLength), &aBufferLength);
	
	// Initialize the Audio Unit and cross fingers =)
	status = AudioUnitInitialize(audioUnit);
    
    setupFFT = vDSP_create_fftsetup(log2f(bufferSize), FFT_RADIX2);
    if (setupFFT == NULL) {
        exit(0);
    }
    
    NSLog(@"Started");
    
}

#pragma mark controll stream
-(void)start {
    // start the audio unit. You should hear something, hopefully :)
    AudioOutputUnitStart(audioUnit);
}
-(void)stop {
    // stop the audio unit
    AudioOutputUnitStop(audioUnit);
}

#pragma mark display

-(void)displayCurve: (float *)input onWind:(int)window wSize:(UInt32)size wType:(NSString*)type wTitle:(NSString*)title {
    if( self.audioProcessorDelegate ){
        // THIS IS NOT OCCURING ON THE MAIN THREAD
        if( [self.audioProcessorDelegate respondsToSelector:@selector(audioProcessor:hasDataReceived:withBufferSize:withType:withWindow: withTitle:)] ){
            [self.audioProcessorDelegate audioProcessor:self hasDataReceived:input withBufferSize:size withType:type withWindow:window withTitle:title];
        }
    }
}

#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList :(UInt32) inNumberFrames
{
    //windowing is not implemented
    
    //NSLog(@"bufferSize=%d | inNumberFrames=%d", bufferSize, inNumberFrames);
    UInt32 mFFTSize = bufferSize;
    UInt32 log2n = log2f(mFFTSize);
    UInt32 nOver2 = mFFTSize/2;
    
    //buffer to 0
    memset(I.realp, 0, bufferSize * sizeof(float));
    memset(I.imagp, 0, bufferSize * sizeof(float));
    memset(C.realp, 0, bufferSize * sizeof(float));
    memset(C.imagp, 0, bufferSize * sizeof(float));
    memset(Cm.realp, 0, bufferSize * sizeof(float));
    memset(Cm.imagp, 0, bufferSize * sizeof(float));
    
    memset(spectrumBuffer, 0, (bufferSize) * sizeof(float));
    memset(spectrumBufferReal, 0, (bufferSize) * sizeof(float));
    memset(spectrumBufferIma, 0, (bufferSize) * sizeof(float));
    
    memset(spectrumBufferPower, 0, (bufferSize) * sizeof(float));
    memset(spectrumBufferPhase, 0, (bufferSize) * sizeof(float));
    
    memset(spectrumModBufferReal, 0, (bufferSize) * sizeof(float));
    memset(spectrumModBufferIma, 0, (bufferSize) * sizeof(float));
    
    memset(spectrumModBufferPower, 0, (bufferSize) * sizeof(float));
    memset(spectrumModBufferPhase, 0, (bufferSize) * sizeof(float));
    
    memset(cepstrumBuffer, 0, (bufferSize) * sizeof(float));

    
    
    //map the input
    SInt16 *editBuffer = audioBufferList->mBuffers[0].mData;
    
    
    /*
     //Normalize the input between -1 and +1
    for (int i = 0; i < mFFTSize; i++) {
        inputBufferFloat[i] = (float) editBuffer[i]/32768.0f;
    }
    
    */
    
    //generate the sample input for analysis. Normalize input for display purpose
    float freq = 50.0f;
    for (int i = 0; i < mFFTSize; i++) {
        inputBufferFloat[i] = 0.5f*(sinf(2*PI*freq*i/(mFFTSize-1)));
        inputBufferFloat[i] *= (float) (((float)mFFTSize-i)/(float)mFFTSize);
        if(i>self.delay) { inputBufferFloat[i] += (float) (((float)mFFTSize-i)/(float)mFFTSize)*0.4f*(sinf(2*3.14159*freq*i/(mFFTSize-1)));}
        //if(i>2*self.delay) { inputBufferFloat[i] += (float) (((float)mFFTSize-i)/(float)mFFTSize)*0.5f*(sinf(2*3.14159*freq*i/(mFFTSize-1)));}
    }
    
    {
        [self displayCurve: inputBufferFloat onWind:1 wSize:mFFTSize wType:kAudio wTitle:@"Input"];
    } //display
    
    //set the input in FFT Buffer
    for (int i = 0; i < mFFTSize; i++) {
        I.realp[i] = inputBufferFloat[i];
        I.imagp[i] = 0.0;
    }
    
    vDSP_fft_zip(setupFFT, &I, 1, log2n, FFT_FORWARD);
    
    //resize because vDSP has a factor 2
    for (int i = 0; i < nOver2; i++) {
        I.realp[i] = 0.5*I.realp[i]/mFFTSize;
        I.imagp[i] = 0.5*I.imagp[i]/mFFTSize;
    }
    
    //Get Power and phase of the Spectrum to have the complex representation
    spectrumBufferPower[0] = I.realp[0]*I.realp[0] + I.imagp[0]*I.imagp[0];
    spectrumBufferPhase[0] = 0;
    
    for (int i = 1; i < nOver2; i++) {
        spectrumBufferReal[i] = I.realp[i];
        spectrumBufferIma[i] = I.imagp[i];
        spectrumBufferPower[i] = logf(sqrtf(spectrumBufferReal[i]*spectrumBufferReal[i] + spectrumBufferIma[i]*spectrumBufferIma[i]));
        spectrumBufferPhase[i] = atanf(spectrumBufferIma[i]/spectrumBufferReal[i]);
    }
    
    {
        [self displayCurve: spectrumBufferPower onWind:2 wSize:nOver2 wType:kSpectrum wTitle:@"Power Spectrum of Input"];
        [self displayCurve: spectrumBufferPhase onWind:3 wSize:nOver2 wType:kSpectrumImag wTitle:@"Phase Spectrum of Input"];
        [self displayCurve: spectrumBufferReal onWind:4 wSize:nOver2 wType:kSpectrumReal wTitle:@"Real Spectrum of Input"];
        [self displayCurve: spectrumBufferIma onWind:5 wSize:nOver2 wType:kSpectrumImag wTitle:@"Imaginary Spectrum of Input"];
    } //display

    //prepare the Cesptrum calculation (before the iFFT) by taking the Natural Log of the Square root of the FFT magnitude
    for (int i = 0; i < nOver2; i++) {
        C.realp[i] = spectrumBufferPower[i];
        C.imagp[i] = spectrumBufferPhase[i];
    }
    
    //apply the iFFT on the Cepstrum pre calculation in order to get the Real Cepstrum
    vDSP_fft_zip(setupFFT, &C, 1, log2n, FFT_INVERSE);
    
    for (int i = 0; i < mFFTSize; i++) {
        Cm.realp[i] = 2*C.realp[i]/mFFTSize;
        Cm.imagp[i] = 2*C.imagp[i]/mFFTSize;
    }
    
    //lifter the cepstrum (complex, so lifter the real and the im parts
    for (int ilifter = lifter; ilifter < mFFTSize; ilifter++) {
        Cm.realp[ilifter] = 0.0f;
        Cm.imagp[ilifter] = 0.0f;
    }
    
    for (int i = 0; i < mFFTSize; i++) {
        cepstrumBuffer[i] = Cm.realp[i]*Cm.realp[i] + Cm.imagp[i]*Cm.imagp[i];
        cepstrumBufferReal[i] = Cm.realp[i];
        cepstrumBufferIma[i] = Cm.imagp[i];
        //cepstrumBufferIma[i] = 0;
    }
    
    {
        [self displayCurve: cepstrumBuffer onWind:6 wSize:mFFTSize wType:kCepstrum wTitle:@"Power Cepstrum of Input"];
        [self displayCurve: cepstrumBufferReal onWind:7 wSize:mFFTSize wType:kCepstrum wTitle:@"Real Cepstrum of Input"];
        [self displayCurve: cepstrumBufferIma onWind:8 wSize:mFFTSize wType:kCepstrum wTitle:@"Imaginary Cepstrum of Input"];
    } //display
    
    //Now that we have lifter (or modified depending the type of application) go back to the spectrum domain
    vDSP_fft_zip(setupFFT, &Cm, 1, log2n, FFT_FORWARD);
    
    for(int i=0; i < nOver2; i++) {
        spectrumModBufferPower[i] = 500*Cm.realp[i]/mFFTSize;
        spectrumModBufferPhase[i] = 500*Cm.imagp[i]/mFFTSize;
    }


    //now we have:
    //real -> the log of the square root of the 'lifted' magnitude
    //im   -> the atan of imaginary part of the 'lifted' spectrum divided by the real part of the 'lifted' spectrum
    //take the exponential of the real part of the FFT of the cesptrum
    //take the tan of the Im part of the FFT of the cepstrum
    //solve an set of two equation of two unknown value to retrieve the spectrum values (Real and Im)
    
    float A;
    float B;
    for (int i = 0; i < nOver2; i++) {
        
        A = expf(spectrumModBufferPower[i]); //A=SQRT(R*R + I*I) (1)
        //B = tanf(spectrumModBufferPhase[i]); //B=I/R (2)
        B = tanf(spectrumBufferPhase[i]); //test: replacing from the orriginal
        spectrumModBufferReal[i] = A / sqrt(1+B*B);  //from (1) and (2) remplacing I in (1)  by B.R
        //from (2)
        spectrumModBufferIma[i] = B*spectrumModBufferReal[i];
        //spectrumModBufferReal[i] = I.realp[i];
        //spectrumModBufferIma[i] = I.imagp[i];
    }
    
    spectrumModBufferReal[0]=0;
    spectrumModBufferIma[0]=0;
    
    {
        [self displayCurve: spectrumModBufferPower onWind:9 wSize:nOver2 wType:kSpectrum wTitle:@"Modified Power spectrum of Input"];
        [self displayCurve: spectrumModBufferPhase onWind:10 wSize:nOver2 wType:kSpectrumImag wTitle:@"Modified Phase spectrum of Input"];
        [self displayCurve: spectrumModBufferReal onWind:11 wSize:nOver2 wType:kSpectrumReal wTitle:@"Modified Real spectrum of Input"];
        [self displayCurve: spectrumModBufferIma onWind:12 wSize:nOver2 wType:kSpectrumImag wTitle:@"Modified Imaginary spectrum of Input"];
    } //display
    
    
    memset(Im.realp, 0, bufferSize * sizeof(float));
    memset(Im.imagp, 0, bufferSize * sizeof(float));
    
    for (int i = 0; i < nOver2; i++) {
        Im.realp[i] = 1000*spectrumModBufferReal[i];
        Im.imagp[i] = 1000*spectrumModBufferIma[i];
    }
    
    //now we have the modified spectrum -> go back to the modified time domain signal
    vDSP_fft_zip(setupFFT, &Im, 1, log2n, FFT_INVERSE);
    
    
    for (int i = 0; i < mFFTSize; i++) {
        inputModBufferFloat[i] = 2*Im.realp[i]/mFFTSize;
    }
    inputModBufferFloat[0] = 0;

    [self displayCurve: inputModBufferFloat onWind:13 wSize:mFFTSize wType:kAudioMod wTitle:@"Modified Input"];
    
    if(self.isModAudio ==  FALSE) { //we dont want the modified audio -> copy original input
        //NSLog(@"isModAudio is FALSE");
        vDSP_fft_zip(setupFFT, &I, 1, log2n, FFT_INVERSE);
        for (int i = 0; i < mFFTSize; i++) {
            //outputBuffer[i] = (SInt16) I.realp[i];
            outputBuffer[i] = (SInt16) 0;
        }
    }
    else {
        //NSLog(@"isModAudio is TRUE");
        for (int i = 0; i < mFFTSize; i++) {
            outputBuffer[i] = (SInt16) Im.realp[i];
        }
    }

	// copy incoming audio data to the audio buffer
	memcpy(audioBuffer.mData, outputBuffer, audioBufferList->mBuffers[0].mDataByteSize);
}


@end
