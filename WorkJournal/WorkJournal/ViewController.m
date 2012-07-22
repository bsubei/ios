//
//  ViewController.m
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollView;
@synthesize todayTextView;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    //NOTE: all views and subviews are created in the nib. None are created within the code.
    
    // size of scrollView is set
    [scrollView setContentSize:CGSizeMake(640, 460)];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTodayTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// dismisses keyboard
- (IBAction)dismissKeyboardButton:(id)sender {
    [todayTextView resignFirstResponder];
}

// brings up option menu
- (IBAction)optionsButton:(id)sender {
}


// detects when view is dragged and dismisses keyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboardButton:nil];
}

@end
