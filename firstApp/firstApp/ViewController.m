//
//  ViewController.m
//  firstApp
//
//  Created by Basheer Subei on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize Label; //label outlet thingie (so i can access its text property)
@synthesize Incrementer; //incrementer OUTLET (so i can access its value and use it in label)
@synthesize DatePicker; // DatePicker outlet (so i can access its date value)
@synthesize Button; // button OUTLET (so i can access its setEnabled property)

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
    [self setIncrementer:nil];
    [self setLabel:nil];
    [self setButton:nil];
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


// called when button is pressed
// takes the date value from datePicker, then stores its weekday in NSString.
// then, it gets incrementer value and adds that many days to current date
// finally, it pops up an AlertView stating chosen and incremented date
- (IBAction)SelectDate:(id)sender {

    // used below to return weekday (as string) of the date 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];

    // now we have a string with the weekday
    NSString *weekday = [formatter stringFromDate: [DatePicker date]];
    
    // value of incrementer
    int incValue = (int)[Incrementer value];
    
    // incremented date (by adding incValue days to the chosen date)
    // paremeter is in seconds, that's why incValue*60*60*24 (that's how many seconds in a day)
    NSDate *incDate = [[DatePicker date] dateByAddingTimeInterval: incValue * 60 * 60 * 24];

    // incremented date (only weekday part) as a string
    NSString *incDayOfWeek = [formatter stringFromDate:incDate];
    
    // message to display in alert. %@ is placeholder for strings and %i for integers
    NSString *msg = [[NSString alloc] initWithFormat:@"that day is a %@, and if we add %i days, it would be a %@",
                     weekday, incValue, incDayOfWeek];
    
    // creates an alertView with title and message and buttonTitle
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Day of the week..." 
                               message: msg
                              delegate:nil 
                     cancelButtonTitle: @"Go away!!!" 
                     otherButtonTitles: nil];
    // actually shows the alert
    [alert show];

    
}


// when toggle button is pressed
// toggles datePicker's setHidden and button's setEnabled (just falsafae) 
- (IBAction)ToggleDate:(id)sender {
    if([DatePicker isHidden])[DatePicker setHidden:NO];
    else [DatePicker setHidden:YES];
    
    if([Button isEnabled])[Button setEnabled:NO];
    else [Button setEnabled:YES];
    
}

// when incrementer is pressed (either + or - ; it doesn't matter).
// accesses incrementer value (from the incrementer outlet) and casts it as an int and then as a string
// the label's text is changed to that string's value
- (IBAction)Incrementer:(id)sender {
    NSString *Value = [[NSString alloc ] initWithFormat:@"%i",(int)[Incrementer value]];
    [Label setText:Value];
    
}
@end
