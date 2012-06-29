//
//  BSSlip.m
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BSSlip.h"

@implementation BSSlip

@synthesize imageView, textView, shredMeButton, moveToTopButton ,FrameX, FrameY, slipIndex, callingViewController;

// Global Constants initialized

//NSString const *SLIP_IMAGE_NAME = @"slip.png";
NSInteger const SLIP_FRAME_WIDTH = 416;
NSInteger const SLIP_FRAME_HEIGHT = 143;





// called when moveToTopButton is pressed
// calls moveSlipToTop in the calling viewController (the only one in this app), and sends in
// this slip's index as parameter
- (void)moveToTopAction:(id)sender
{
    [[self callingViewController] moveSlipToTop:slipIndex];
    
    
}


- (void)shredMeAction:(id)sender
{
    [[self callingViewController] shredSlip:slipIndex];
    
    
}


//initializing each slip using overriden method 
//TODO review about passing in index and caller (very kludgey?)
- (id)initWithFrame:(CGRect)frame withIndex:(NSInteger)index withCaller:(id)caller
{
    // some code already here that inits UIView stuff (so we don't have to handle as we subclass it)
    self = [super initWithFrame:frame];
    if (self) {
        
        // now set frame coordinates for slip
        [self setFrameX:frame.origin.x];
        [self setFrameY:frame.origin.y];
       
        //set slip index
        [self setSlipIndex:index];
        
        // init the textView            // ***frame location of TextView is relative to slip frame***
        [self setTextView: [[UITextView alloc]initWithFrame:CGRectMake( 20 // TODO TWEAK
                                                               , 20
                                                               ,SLIP_FRAME_WIDTH - 200
                                                               , SLIP_FRAME_HEIGHT - 100)]];
        // set TextView to transparent
        [[self textView] setBackgroundColor:[UIColor clearColor]];
        
        // set TextView's delegate to be the calling viewController
        [[self textView] setDelegate:caller];
        
        // TODO textView font and details (char limit)...
        
        // for debugging
        [[self textView] setText: [[NSString alloc]initWithFormat:@"    original position: %i", index]];
        
        
        
        // create reference to caller (parent viewController)
        [self setCallingViewController: caller];
        
        //create the moveToTop button
        
            // creating it
            [self setMoveToTopButton: [UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
            // setting button frame //TODO TWEAK HERE
            [[self moveToTopButton] setFrame: CGRectMake(10, 20, 50, 30)];
            
        // set title
//            [[self moveToTopButton] setTitle: [[NSString alloc] initWithFormat:@"%i", index] 
//                 forState:(UIControlState)UIControlStateNormal];

                       
        
            //set target (call event when touched)
            [[self moveToTopButton] addTarget:self 
                                       action:@selector(moveToTopAction:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        
        // TODO more tweaking for moveToTop button
        
        
        
        // create the shredMeButton
        
        // creating it
        [self setShredMeButton: [UIButton buttonWithType:UIButtonTypeInfoDark]];
        // setting button frame //TODO TWEAK HERE
        [[self shredMeButton] setFrame: CGRectMake(100, 20, 50, 30)];
        //set target (call event when touched)
        [[self shredMeButton] addTarget:self 
                                   action:@selector(shredMeAction:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        

        
        
        // now set slip image using given path
        
            // first get path
            NSString *path = [[NSBundle mainBundle] pathForResource:@"slip" ofType:@"png"];
            
            //now create a new image from that path
            UIImage *newImage = [[UIImage alloc]initWithContentsOfFile: path];

        
        //actually set imageView object ***(and init it at the same time)*** with our obtained image
        [self setImageView: [[UIImageView alloc]initWithImage:newImage]];
        
        // NOW ADD the imageView as a subview of slip
        [self addSubview:imageView];
        
        // NOW ADD the textView as a subview of the slip
        [self addSubview:textView];
        
        // add shred button
        [self addSubview:shredMeButton];
        
        //finally, add button to slip subview
        [self addSubview:moveToTopButton];
        
        // makes sure our button is in front
//        [self bringSubviewToFront:moveToTopButton];
        

            
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
