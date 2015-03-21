//
//  MyAudioWindow.m
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

#import "MyAudioViewController.h"
#import "AudioProcessor.h"

@implementation MyAudioViewController
@synthesize topLabel, CepstrumValues;
@synthesize audioSwitch, audioProcessor, plotterView1, plotterView2, plotterView3, plotterView4, plotterView5, plotterView6;
@synthesize delay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lifter.minimumValue = 0;
        self.lifter.maximumValue = bufferSize;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setAudioSwitch:nil];
    [self setTopLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark AU control
/*
 UISlider Move
*/
-(IBAction)lifterSliderMoved:(id)sender {
    UISlider *slider = (UISlider *)sender;
    audioProcessor.lifter = [slider value];
    self.lifterLabel.text = [NSString stringWithFormat:@"lifter:%3d", (int)[slider value]];
    //NSLog(@"Lifter SliderValue ... %d",(int)[slider value]);
}

-(IBAction)minusLifterTouched:(id)sender {
    audioProcessor.lifter -= 1;
    [[self lifter] setValue:audioProcessor.lifter];
    self.lifterLabel.text = [NSString stringWithFormat:@"lifter:%3d", (int)audioProcessor.lifter];
    NSLog(@"Lifter Minus Touched");
}

-(IBAction)plusLifterTouched:(id)sender {
    audioProcessor.lifter += 1;
    [[self lifter] setValue:audioProcessor.lifter];
    self.lifterLabel.text = [NSString stringWithFormat:@"lifter:%3d", (int)audioProcessor.lifter];
    NSLog(@"Lifter Plus Touched");
}

-(IBAction)delaySliderMoved:(id)sender {
    UISlider *slider = (UISlider *)sender;
    audioProcessor.delay = [slider value];
    self.delayLabel.text = [NSString stringWithFormat:@"delay:%3d", (int)[slider value]];
    //NSLog(@"Delay SliderValue ... %d",(int)[slider value]);
}

-(IBAction)minusDelayTouched:(id)sender {
    audioProcessor.delay -= 1;
    [[self delay] setValue:audioProcessor.delay];
    self.delayLabel.text = [NSString stringWithFormat:@"delay:%3d", (int)audioProcessor.delay];
    NSLog(@"Delay Minus Touched");
}

-(IBAction)plusDelayTouched:(id)sender {
    audioProcessor.delay += 1;
    [[self delay] setValue:audioProcessor.delay];
    self.delayLabel.text = [NSString stringWithFormat:@"delay:%3d", (int)audioProcessor.delay];
    NSLog(@"Delay Plus Touched");
}

-(IBAction)zoomFFTSliderMoved:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.plotterView1.zoomFFT = [slider value];
    self.plotterView2.zoomFFT = [slider value];
    self.plotterView3.zoomFFT = [slider value];
    self.plotterView4.zoomFFT = [slider value];
    self.plotterView5.zoomFFT = [slider value];
    self.plotterView6.zoomFFT = [slider value];
    self.plotterView7.zoomFFT = [slider value];
    self.plotterView8.zoomFFT = [slider value];
    self.plotterView9.zoomFFT = [slider value];
    self.plotterView10.zoomFFT = [slider value];
    self.plotterView11.zoomFFT = [slider value];
    self.plotterView12.zoomFFT = [slider value];
    self.plotterView13.zoomFFT = [slider value];
    //self.delayLabel.text = [NSString stringWithFormat:@"zoom:%3d", (int)[slider value]];
    //NSLog(@"Delay SliderValue ... %d",(int)[slider value]);
}


-(IBAction)note1On:(id)sender {
    audioProcessor.note1 = 1;
    NSLog(@"Note1 On");
}
-(IBAction)note1Off:(id)sender {
    audioProcessor.note1 = 0;
    NSLog(@"Note1 Off");
}

-(IBAction)note2On:(id)sender {
    audioProcessor.note2 = 1;
    NSLog(@"Note2 On");
}
-(IBAction)note2Off:(id)sender {
    audioProcessor.note2 = 0;
    NSLog(@"Note2 Off");
}

-(IBAction)note3On:(id)sender {
    audioProcessor.note3 = 1;
    NSLog(@"Note3 On");
}
-(IBAction)note3Off:(id)sender {
    audioProcessor.note3 = 0;
    NSLog(@"Note3 Off");
}

-(IBAction)note4On:(id)sender {
    audioProcessor.note4 = 1;
    NSLog(@"Note4 On");
}
-(IBAction)note4Off:(id)sender {
    audioProcessor.note4 = 0;
    NSLog(@"Note4 Off");
}



/*
 Switchtes AudioUnit from AudioProcessor on and off.
 Checks if processor exists. If not it will initialized.
 
 Nevermind that indicator and label stuff. I like it a bit fancy ;)
 */
- (IBAction)audioSwitch:(id)sender {
    if (!audioSwitch.on) {
        [self showLabelWithText:@"Stopping AudioUnit"];
        [audioProcessor stop];
        [self showLabelWithText:@"AudioUnit stopped"];
    } else {
        if (audioProcessor == nil) {
            audioProcessor = [[AudioProcessor alloc] initWithAudioProcessorDelegate:self];
            self.plotterView1.shouldDraw = TRUE;
            self.plotterView2.shouldDraw = TRUE;
            self.plotterView3.shouldDraw = TRUE;
            self.plotterView4.shouldDraw = TRUE;
            self.plotterView5.shouldDraw = TRUE;
            self.plotterView6.shouldDraw = TRUE;
            self.plotterView7.shouldDraw = TRUE;
            self.plotterView8.shouldDraw = TRUE;
            self.plotterView9.shouldDraw = TRUE;
            self.plotterView10.shouldDraw = TRUE;
            self.plotterView11.shouldDraw = TRUE;
            self.plotterView12.shouldDraw = TRUE;
            self.plotterView13.shouldDraw = TRUE;
        }
        [self showLabelWithText:@"Starting up AudioUnit"];
        [audioProcessor start];
        [self showLabelWithText:@"AudioUnit running"];
    }
    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:3.5];
}

- (IBAction)audioModSwitch:(id)sender {
    BOOL state = [sender isOn];
    if (state) {
        NSLog(@"----isModAudio is TRUE");
        audioProcessor.isModAudio = TRUE;
    }
    else {
        NSLog(@"----isModAudio is FALSE");
        audioProcessor.isModAudio = FALSE;
    }
}

#pragma mark Labels

- (void)showLabelWithText:(NSString*)labelText {
    [topLabel setText:labelText];
}

#pragma mark cleanup

- (void)dealloc {
    [audioProcessor release];
    [audioSwitch release];
    [topLabel release];
    [super dealloc];
}


#pragma Min and Max
- (float) getMin: (float *)data withLenght:(UInt32)lenght {
    float min = 100000;
    for(UInt32 i=0 ; i < lenght; i++) {
        if(data[i] < min) min = data[i];
    }
    return min;
}

- (float) getMax: (float *)data withLenght:(UInt32)lenght {
    float max = -100000;
    for(UInt32 i=0 ; i < lenght; i++) {
        if(data[i] > max) max = data[i];
    }
    return max;
}



#pragma mark - AudioProcessorDelegate
-(void) audioProcessor:(AudioProcessor *)audioProcessor hasDataReceived:(float *)buffer withBufferSize:(UInt32)bufferSize withType:(NSString *)type withWindow:(int)window withTitle:(NSString*)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        //set the window
        NSString *plotterWindow = [NSString stringWithFormat:@"plotterView%d", window];
        PlotterView* plotWindow = [self valueForKey:plotterWindow];
        plotWindow.data = buffer;
        plotWindow.dataSize = bufferSize;
        plotWindow.type = [NSString stringWithFormat:@"%@", type];
        plotWindow.title = [NSString stringWithFormat:@"%@", title];
        plotWindow.minData = [self getMin:buffer withLenght:bufferSize];
        plotWindow.maxData = [self getMax:buffer withLenght:bufferSize];
        
        if(!(plotWindow.maxData == 0 && plotWindow.minData == 0)) {
            [plotWindow setNeedsDisplay];
        }
    });
}




@end
