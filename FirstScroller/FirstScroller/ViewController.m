//
//  ViewController.m
//  FirstScroller
//
//  Created by Basheer Subei on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

//@synthesize scrollView1;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    




        [scrollView setContentSize:CGSizeMake(900,900)];
    //    tempScrollView.contentSize=CGSizeMake(ImageView.frame.size.width, ImageView.frame.size.height);
    
//    [mainView sendSubviewToBack: self.view];
//    [self.view setBackgroundColor:[UIColor clearColor]];
//    [ScrollableArea setBackgroundColor:[UIColor clearColor]];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    ImageView = nil;
    ScrollableArea = nil;
    scrollView = nil;
    mainView = nil;
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
