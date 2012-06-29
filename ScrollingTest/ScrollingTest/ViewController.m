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

@synthesize dismissKeyboardOutlet;
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
- (void)shredSlip:(int)slipIndex
{
    // no slips to shred or incorrect parameter
    if ([allSlips count] == 0 || slipIndex >= [allSlips count] || slipIndex < 0) {
        //TODO debugging
        NSLog(@"WTF? %i", slipIndex);
        
        return;
    }
    // create a reference to the slip that's to be shredded
    BSSlip *thisSlip = [allSlips objectAtIndex:slipIndex];
    
    //remove slip from view
    [thisSlip removeFromSuperview];

    // remove slip from array
    [allSlips removeObjectAtIndex:slipIndex];
    //update scrollView
    [self updateScrollViewContentSize];
    
    //update dismissKeyboard size
    [self updateDismissKeyboardButtonSize];

    [self updateIndicesForAllSlips];
    
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
    [self updateDismissKeyboardButtonSize];
}


#pragma mark - Updating Methods

//  update slipIndex of rearranged slips // TODO need to do this in its own thread
- (void)updateIndicesForAllSlips
{
        for (int i =0; i<[allSlips count]; i++) {
        [[[self allSlips] objectAtIndex:i] setSlipIndex:i];    
    }
}


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
        

        [self updateIndicesForAllSlips];
        
        // re(draws) all slips
        [self updateSlipsInView];
    }
}

- (void)updateDismissKeyboardButtonSize
{
    
    //resizes dismiss Keyboard button //TODO tweak this along with above
    [[self dismissKeyboardOutlet] setFrame:CGRectMake(0,0,
                                                      scrollView.frame.size.width
                                                      , scrollView.frame.size.height* ([allSlips count] /3.0) )];
    
}

// called whenever slips are created or shredded
// TODO tweak these values same as in createNewSlip (maybe use constants for slip size and spacing)
// TODO see if we want this animated!!!
- (void)updateScrollViewContentSize
{
    
    //animation description (like opening tag)  //TODO tweak animation values
    [UIView beginAnimations:@"MoveAndStrech" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.scrollView setContentSize:CGSizeMake(
                                               scrollView.frame.size.width
                                               , scrollView.frame.size.height* ([allSlips count] /3.0) )];
    
    // perform animations (like closing tag)
    [UIView commitAnimations];

}

// TODO tweak animations on this
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
// button to dismiss keyboard
- (IBAction)invisibleDismissKeyboardButton:(id)sender {
     NSLog(@"dismissKeyboard");
    if ([allSlips count] >0) {
       
        // TODO must figure out WHICH slip is being edited and tell it to resignFirstResponder
        // TODO check if kludge solution of resigning first responders for all slips works (no bugs?)
        for (int i=0; i<[allSlips count]; i++) {
                [[[allSlips objectAtIndex:i] textView] resignFirstResponder];
        }
        
    }
    
}
// button for testing 
- (IBAction)shredSlipButton:(id)sender 
{
    [self shredSlip:0];
}

// button for testing (adds new slip; update taken care of inside createNewSlip:)
- (IBAction)newSlipButton:(id)sender
{
    [self createNewSlip];
}

#pragma mark - Delegate Methods

// called when user first starts editing a textField 
//TODO make it pass the slipIndex so that dismissKeyboard button knows who's slip to resignFirstResponder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"began editing");
}

// called when user hits return key (returning a yes makes it act default)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    
    return YES;
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
    
    //TODO fix this:put dismissKeyboard back
    [scrollView sendSubviewToBack:dismissKeyboardOutlet];
    


}


// TODO watch this (maybe unload everything in allSlips? or do that after enter background or quit)
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setBackgroundImage:nil];
    [self setDismissKeyboardOutlet:nil];
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
