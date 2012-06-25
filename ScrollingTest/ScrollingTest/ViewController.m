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

// called in appDidFinishLaunchingWithOptions (TODO call when loading data in appDidEnterForeground???)
- (void)initializeAllSlipsArray
{
    allSlips = [[NSMutableArray alloc]init];
}

// returns new Slip object ***(assumes allSlips is initialized)*** and is private and so not in .h file
// returned slip already has ready imageView and (soon) textView
- (BSSlip *)initializeNewSlip
{
    return [[BSSlip alloc]initWithFrame:
            CGRectMake(20
                       , 30 + (SLIP_FRAME_HEIGHT+ 20)*  [allSlips count] //TODO tweak AND store this somehow
                       , SLIP_FRAME_WIDTH
                       , SLIP_FRAME_HEIGHT)];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // setting initial ContentSize of scrollView (diff from frame size) and making it transparent 
    [scrollView setContentSize: CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height*2)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    
//debug
    [self initializeAllSlipsArray];
    
    // create the first slip at top
    BSSlip *firstSlip = [self initializeNewSlip];

    // add to array
    [allSlips addObject: firstSlip];
    
    // TODO FIX scrolling the slips
    //add new slip to scrollView (root view for now)
    [self.view addSubview:firstSlip];
    
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
