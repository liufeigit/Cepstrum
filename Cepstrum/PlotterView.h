//
//  PlotterView.h
//  Cepstrum
//
//  Created by PM on 19/01/15.
//


#import <UIKit/UIKit.h>
#import "define.h"



@interface PlotterView : UIView
//Data
@property (nonatomic) float *data;

//Min/Max
@property (nonatomic) float minData;
@property (nonatomic) float maxData;

//DataSize
@property (nonatomic) UInt32 dataSize;



@property (nonatomic) UInt32 numberOfDisplay;

@property (nonatomic) bool shouldDraw;
@property (nonatomic) int zoomFFT;

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* minLabel;
@property (nonatomic, strong) IBOutlet UILabel* maxLabel;



- (void)drawLineGraphWithContext:(CGContextRef)ctx;
- (void)drawTextWithContext:(CGContextRef)ctx;


@end
