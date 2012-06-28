//
//  ViewController.m
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BSSlip.h"
#import "AppDelegate.h"

@implementation ViewController

@synthesize scrollView;
@synthesize backgroundImage;
@synthesize allSlips;

// TODO read more about memory warning (app must be lite on memory)
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Creating and Destroying Slips

// method that deletes last slip and updates scroll
// TODO transform this method to one that deletes specified slips (not just last)
- (void)shredSlip
{
    // no slips to shred
    if ([allSlips count] == 0) {
        return;
    }
    
    //remove slip from view
    [[allSlips lastObject] removeFromSuperview];

    // remove slip from array
    [allSlips removeLastObject];
    //update scrollView
    [self updateScrollViewContentSize];

    //update all slips (if not last one deleted)
    [self updateSlipsInView];
    
}

// creates a new slip object, then adds it to allSlips array, then adds it as subview
// ***(assumes allSlips is initialized)*** and is private and so not in .h file
// slip already has ready imageView and (soon) textView
- (void)createNewSlip
{
    
    //creating newslip (uses getSlipFrame to return frame based on position in allSlips array)
    // passes in what index this slip is in and passes in the caller (self)
    BSSlip *newSlip = [ [BSSlip alloc]initWithFrame: [self getSlipFrame:[allSlips count] ] withIndex:[allSlips count] withCaller: self ];
    
    // add it to array
    [allSlips addObject: newSlip];
    
    //add new slip to scrollView 
    [scrollView addSubview:newSlip];
    
    //update as more slips are added
    [self updateScrollViewContentSize];
    
}


#pragma mark - Updating Methods

//method that moves slip to top (becomes first)
- (void)moveSlipToTop:(NSInteger)index
{
    //do nothing if slip is already top
    // and check for crazy values that cause exceptions
    if(index > 0 && index < [allSlips count]){
        // get current slip
        BSSlip *currentSlip = [[self allSlips] objectAtIndex:index];
        //insert it at top
        [allSlips insertObject:currentSlip atIndex:0];
        //remove old instance of current slip
        [allSlips removeObjectAtIndex:index+1 ];
        
        //  change slipIndex of rearranged slips
        for (int i =0; i<[allSlips count]; i++) {
            [[[self allSlips] objectAtIndex:i] setSlipIndex:i];    
        }
        
        // re(draws) all slips
        [self updateSlipsInView];
    }
}

// called whenever slips are created or shredded
// TODO tweak these values same as in createNewSlip (maybe use constants for slip size and spacing)
- (void)updateScrollViewContentSize
{
    [self.scrollView setContentSize:CGSizeMake(
                                               scrollView.frame.size.width
                                               , scrollView.frame.size.height* ([allSlips count] /3.0) )];
}

// TODO add animations to this
// method that updates slip locations and re(moves) in view
- (void)updateSlipsInView
{
    // for every slip 
    for (int i=0; i<[allSlips count]; i++) {
        
        //get reference to current slip
        BSSlip *currentSlip = [allSlips objectAtIndex:i];
        
        //get its new frame
        CGRect newFrame = [self getSlipFrame:i];
        //set that slip's frameX to be the x we got from newFrame
        [ currentSlip setFrameX:newFrame.origin.x];
        //set that slip's frameY to be the y we got from newFrame
        [currentSlip setFrameY:newFrame.origin.y];
        
        
        //animation description (like opening tag)  //TODO tweak animation values
        [UIView beginAnimations:@"MoveAndStrech" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // D'OH!! so stupid! how could i have missed ACTUALLY CHANGING THE FRAME of each slips?
        [currentSlip setFrame:CGRectMake([currentSlip FrameX], [currentSlip FrameY], SLIP_FRAME_WIDTH, SLIP_FRAME_HEIGHT)];
        
        // perform animations (like closing tag)
        [UIView commitAnimations];
        
    } // end for loop
    
}


#pragma mark - Helper Methods

// called in appDidFinishLaunchingWithOptions (TODO call when loading data in appDidEnterForeground???)
- (void)initializeAllSlipsArray
{
    allSlips = [[NSMutableArray alloc]init];
}

// returns frame of slip depending on its order in allSlips array
// created because it will be reused in updateSlipsInView & in createNewSlip
- (CGRect)getSlipFrame:(NSInteger)index
{
    return CGRectMake(20
                      , 30 + (SLIP_FRAME_HEIGHT+ 20)*  index //TODO tweak AND store this somehow
                      , SLIP_FRAME_WIDTH
                      , SLIP_FRAME_HEIGHT);
}

#pragma mark - Buttons
// button for testing 
- (IBAction)shredSlipButton:(id)sender 
{
    [self shredSlip];
}

// button for testing (adds new slip; update taken care of inside createNewSlip:)
- (IBAction)newSlipButton:(id)sender
{
    [self createNewSlip];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // setting initial ContentSize of scrollView (diff from frame size) and making it transparent 
    [self updateScrollViewContentSize];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    // loading the scrollView as a subview of root view
    [self.view addSubview:scrollView];

}


// TODO watch this (maybe unload everything in allSlips? or do that after enter background or quit)
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setBackgroundImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
