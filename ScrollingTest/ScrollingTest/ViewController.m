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

// called whenever slips are created or shredded
// TODO tweak these values same as in createNewSlip (maybe use constants for slip size and spacing)
- (void)updateScrollViewContentSize
{
        [self.scrollView setContentSize:CGSizeMake(
                                                   scrollView.frame.size.width
                                                   , scrollView.frame.size.height* ([allSlips count] /3.0) )];
}

// button for testing (deletes last slip and updates scroll)
- (IBAction)shredSlipButton:(id)sender {
    [[allSlips lastObject] removeFromSuperview];
    [allSlips removeLastObject];
    [self updateScrollViewContentSize];
    
}

// button for testing (adds new slip; update taken care of inside createNewSlip:)
- (IBAction)newSlipButton:(id)sender {
    [self createNewSlip];
}

// called in appDidFinishLaunchingWithOptions (TODO call when loading data in appDidEnterForeground???)
- (void)initializeAllSlipsArray
{
    allSlips = [[NSMutableArray alloc]init];
}

// creates a new slip object, then adds it to allSlips array, then adds it as subview
// ***(assumes allSlips is initialized)*** and is private and so not in .h file
// slip already has ready imageView and (soon) textView
- (void)createNewSlip
{
    //creating newslip
    BSSlip *newSlip = [[BSSlip alloc]initWithFrame:
            CGRectMake(20
                       , 30 + (SLIP_FRAME_HEIGHT+ 20)*  [allSlips count] //TODO tweak AND store this somehow
                       , SLIP_FRAME_WIDTH
                       , SLIP_FRAME_HEIGHT)];
    
    // add it to array
    [allSlips addObject: newSlip];
    
    //add new slip to scrollView 
    [scrollView addSubview:newSlip];
    
    //update as more slips are added
    [self updateScrollViewContentSize];
    
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


    
    // create the first slip at top
//    [self createNewSlip];


    

    
//    [self.view sendSubviewToBack:backgroundImage];

    
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
