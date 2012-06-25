//
//  BSSlip.m
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BSSlip.h"

@implementation BSSlip

@synthesize imageView, textView, FrameX, FrameY;


// Global Constants initialized

//NSString const *SLIP_IMAGE_NAME = @"slip.png";
NSInteger const SLIP_FRAME_WIDTH = 416;
NSInteger const SLIP_FRAME_HEIGHT = 143;


//initializing each slip using overriden method
- (id)initWithFrame:(CGRect)frame
{
    // some code already here (maybe for some null-value checking)
    self = [super initWithFrame:frame];
    if (self) {
        
        // now set frame coordinates for slip
        [self setFrameX:frame.origin.x];
        [self setFrameY:frame.origin.y];
       
        // TODO init the textView
        
        
        // now set slip image using given path
        
            // first get path
            NSString *path = [[NSBundle mainBundle] pathForResource:@"slip" ofType:@"png"];
            
            //now create a new image from that path
            UIImage *newImage = [[UIImage alloc]initWithContentsOfFile: path];

        
        //actually set imageView object ***(and init it at the same time)*** with our obtained image
        [self setImageView: [[UIImageView alloc]initWithImage:newImage]];
        
        // NOW ADD the imageView as a subview of slip
        [self addSubview:imageView];
        
        // TODO NOW ADD the textView as a subview of the slip
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
