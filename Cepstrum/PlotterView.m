//
//  PlotterView.m
//  Cepstrum
//
//  Created by PM on 19/01/15.
//

#import "PlotterView.h"

@implementation PlotterView
@synthesize data, dataSize, type, minData, maxData;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.shouldDraw = FALSE;
        self.numberOfDisplay = 0;
        self.zoomFFT = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    if(self.shouldDraw) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        /*
        CGContextSetLineWidth(context, 0.6);
        CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGFloat dash[] = {2.0, 2.0};
        CGContextSetLineDash(context, 0.0, dash, 2);
        
        // How many lines for the GRID
        int howMany = (kDefaultGraphWidth - kOffsetX) / kStepX;
        // Here the lines go Vertical
        for (int i = 0; i <= howMany; i++)
        {
            CGContextMoveToPoint(context, kOffsetX + i * kStepX, kGraphTop);
            CGContextAddLineToPoint(context, kOffsetX + i * kStepX, kGraphBottom);
        }
        
        int howManyHorizontal = (kGraphBottom - kGraphTop - kOffsetY) / kStepY;
        // Here the lines go Horizontal
        for (int i = 0; i <= howManyHorizontal; i++)
        {
            CGContextMoveToPoint(context, kOffsetX, kGraphBottom - kOffsetY - i * kStepY);
            CGContextAddLineToPoint(context, kDefaultGraphWidth, kGraphBottom - kOffsetY - i * kStepY);
        }
        
        CGContextStrokePath(context);
        
        //remove the dash for the following lines
        CGContextSetLineDash(context, 0, NULL, 0); // Remove the dash
        */
        
        [self drawLineGraphWithContext:context];
        //[self drawTextWithContext:context];
    }
    self.numberOfDisplay++;
}

- (void)drawTextWithContext:(CGContextRef)context {
    // Drawing text
    
    CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] CGColor]);
    
    //Drawing Horizontal text
    CGContextSetTextMatrix (context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    NSString *theTextH = @"Horizontal";
    CGContextShowTextAtPoint(context, 130, 10, [theTextH cStringUsingEncoding:NSUTF8StringEncoding], [theTextH length]);
    
    //drawing vertical text
    CGContextSetTextMatrix(context, CGAffineTransformRotate(CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0), M_PI / 2));
    NSString *theTextV = @"Vertical";
    CGContextShowTextAtPoint(context, 10, 80, [theTextV cStringUsingEncoding:NSUTF8StringEncoding], [theTextV length]);
    
    //drawing horizontal axis values
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] CGColor]);
    for (int i = 1; i < self.dataSize; i++)
    {
        NSString *theText = [NSString stringWithFormat:@"%d", i];
        CGSize labelSize = [theText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:18]];
        CGContextShowTextAtPoint(context, kOffsetX + i * kStepX - labelSize.width/2, kGraphBottom - 5, [theText cStringUsingEncoding:NSUTF8StringEncoding], [theText length]);
    }
}

- (void)drawDataCurveWithData: (float *)localData withDataSize: (float)Size withDataMin:(float)localMinData withDataMax:(float)localMaxData withColor:(UIColor *)color withContext:(CGContextRef)ctx withZoom:(int)zoom withType:(NSString *)mytype{

    if(!(localMaxData == localMinData)) {
        //NSLog(@"%@", mytype);
        CGContextSetLineWidth(ctx, 1.0);
        float y;
        float x;
        CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
        int intSample = 0;
        y = kGraphWindowHeight * (localMaxData - localData[intSample])/ (localMaxData-localMinData);
        CGContextMoveToPoint(ctx, intSample, y);
        for (intSample = 1 ; intSample < Size ; intSample ++ ) {
            y = kGraphWindowHeight * (localMaxData - localData[intSample])/ (localMaxData-localMinData);
            x = zoom*intSample*kGraphWindowWidth/Size;
            CGContextAddLineToPoint(ctx, x , y);
        }
        CGContextStrokePath(ctx);
    }
}

- (void)drawLineGraphWithContext:(CGContextRef)ctx {
    
    self.minLabel.text = [NSString stringWithFormat:@"%.2f", self.minData];
    self.maxLabel.text = [NSString stringWithFormat:@"%.2f", self.maxData];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.title];
    
    if([self.type isEqualToString:@"audio"]) {
        UIColor *color = [UIColor colorWithRed:1.0 green:0.6 blue:0 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:1 withType:self.type];
    }
    else if([self.type isEqualToString:@"audioMod"]) {
        UIColor *color = [UIColor colorWithRed:1.0 green:0.6 blue:0 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:self.zoomFFT withType:self.type];
    }
    else if ([self.type isEqualToString:@"spectrum"]) {
        UIColor *color = [UIColor colorWithRed:0.0 green:0.6 blue:0.2 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:self.zoomFFT withType:self.type];
    }
    else if([self.type isEqualToString:@"spectrumR"]) {
        UIColor *color = [UIColor colorWithRed:0.0 green:0.7 blue:0.4 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:self.zoomFFT withType:self.type];
    }
    else if([self.type isEqualToString:@"spectrumI"]) {
        UIColor *color = [UIColor colorWithRed:0.0 green:0.9 blue:0.4 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:self.zoomFFT withType:self.type];
    }
    else if ([self.type isEqualToString:@"cepstrum"]) {
        UIColor *color = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:cepstrumZoom withType:self.type];
    }
    else if ([self.type isEqualToString:@"cepstrumR"]) {
        UIColor *color = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:cepstrumZoom withType:self.type];
    }
    else if ([self.type isEqualToString:@"cepstrumI"]) {
        UIColor *color = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0];
        [self drawDataCurveWithData:self.data withDataSize:self.dataSize withDataMin:self.minData withDataMax:self.maxData withColor:color withContext:ctx withZoom:cepstrumZoom withType:self.type];
    }
}

@end
