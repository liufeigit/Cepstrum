//
//  MyAudioWindow.h
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

#import <UIKit/UIKit.h>
#import "PlotterView.h"
#import "AudioProcessor.h"




@interface MyAudioViewController : UIViewController <AudioProcessorDelegate>

@property (retain, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *audioModSwitch;
@property (retain, nonatomic) AudioProcessor *audioProcessor;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView1;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView2;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView3;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView4;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView5;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView6;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView7;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView8;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView9;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView10;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView11;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView12;
@property (retain, nonatomic) IBOutlet PlotterView *plotterView13;
@property (retain, nonatomic) IBOutlet UILabel *topLabel;
@property (retain, nonatomic) IBOutlet UISlider *lifter;
@property (retain, nonatomic) IBOutlet UISlider *delay;
@property (retain, nonatomic) IBOutlet UISlider *freq;
@property (retain, nonatomic) IBOutlet UISlider *zoomFFT;
@property (retain, nonatomic) IBOutlet UILabel *CepstrumValues;

@property (retain, nonatomic) IBOutlet UIButton *note1;
@property (retain, nonatomic) IBOutlet UIButton *note2;
@property (retain, nonatomic) IBOutlet UIButton *note3;
@property (retain, nonatomic) IBOutlet UIButton *note4;

@property (retain, nonatomic) IBOutlet UIButton *minusDelay;
@property (retain, nonatomic) IBOutlet UIButton *plusDelay;
@property (retain, nonatomic) IBOutlet UIButton *minusLifter;
@property (retain, nonatomic) IBOutlet UIButton *plusLifter;

@property (retain, nonatomic) IBOutlet UILabel *delayLabel;
@property (retain, nonatomic) IBOutlet UILabel *lifterLabel;

// actions
- (IBAction)audioSwitch:(id)sender;

// ui element manipulation
- (void)showLabelWithText:(NSString*)labelText;

- (IBAction)note1On:(id)sender;
- (IBAction)note2On:(id)sender;
- (IBAction)note3On:(id)sender;
- (IBAction)note4On:(id)sender;

- (IBAction)note1Off:(id)sender;
- (IBAction)note2Off:(id)sender;
- (IBAction)note3Off:(id)sender;
- (IBAction)note4Off:(id)sender;

- (IBAction)minusDelayTouched:(id)sender;
- (IBAction)plusDelayTouched:(id)sender;

- (IBAction)minusLifterTouched:(id)sender;
- (IBAction)plusLifterTouched:(id)sender;


@end
