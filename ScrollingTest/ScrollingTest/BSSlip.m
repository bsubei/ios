//
//  BSSlip.m
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BSSlip.h"

@implementation BSSlip

@synthesize imageView, textField, shredMeButton, moveToTopButton ,FrameX, FrameY, slipIndex, callingViewController;

// Global Constants initialized

//NSString const *SLIP_IMAGE_NAME = @"slip.png";
NSInteger const SLIP_FRAME_WIDTH = 208;
NSInteger const SLIP_FRAME_HEIGHT = 75;



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


//creates buttons for a specific slip (used when a blank slip is filled)
- (void)createButtonsForSlip
{
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
    
    
    
    
    // add shred button
    [self addSubview:shredMeButton];
    
    //finally, add button to slip subview
    [self addSubview:moveToTopButton];
    

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
        //TODO Debug index bug
//        NSLog(@"within Slip Init: %i", index);
        
        // init the textField            // ***frame location of textField is relative to slip frame***
        [self setTextField: [[UITextField alloc]initWithFrame:CGRectMake( 20 // TODO TWEAK
                                                               , 20
                                                               ,SLIP_FRAME_WIDTH - 20
                                                               , SLIP_FRAME_HEIGHT - 10)]];
        // set textField to transparent
        [[self textField] setBackgroundColor:[UIColor clearColor]];
        
        // set textField's delegate to be the calling viewController
        [[self textField] setDelegate:caller];
        
        //IMPORTANT BUG FIX, need to set initial text string to empty (trying to access a nil text string [top
        // blank] gives exceptions)
        //from now on, all slips start off with "" empty text string
        [[self textField] setText:@""];
        
        // TODO textField font and details (char limit)...
        
        // for debugging
//        [[self textField] setText: [[NSString alloc]initWithFormat:@"    original position: %i", index]];
        
        // now set slip image using given path
        
        // first get path
        NSString *path = [[NSBundle mainBundle] pathForResource:@"slip" ofType:@"png"];
        
        //now create a new image from that path
        UIImage *newImage = [[UIImage alloc]initWithContentsOfFile: path];
        
        
        //actually set imageView object ***(and init it at the same time)*** with our obtained image
        [self setImageView: [[UIImageView alloc]initWithImage:newImage]];
        
        // NOW ADD the imageView as a subview of slip
        [self addSubview:imageView];
        
        // NOW ADD the textField as a subview of the slip
        [self addSubview:textField];
        
        
        
        // create reference to caller (parent viewController)
        [self setCallingViewController: caller];
        
        
        // don't create buttons if we are top blank slip
        if (index !=0) {
            
            [self createButtonsForSlip];
            
        } //end if (if we are not top slip)

        // makes sure our button is in front
//        [self bringSubviewToFront:moveToTopButton];
        

            
    }
    return self;
}// end init method

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
