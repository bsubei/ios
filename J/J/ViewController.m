//
//  ViewController.m
//  J
//
//  Created by Basheer Subei on 22.09.12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize topScreenIsVisible;
@synthesize overviewArray;

NSString *DEFAULT_TEXT = @"Enter your J here...";

#define TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT @"Enter today's journal here..."

- (void)dismissKeyboard
{
    [self.topScreenTextView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    [self setTopScreenIsVisible:YES];
    
    // set up (tap recognizer for the infoView)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setNumberOfTapsRequired:1];
    [self.topScreenView addGestureRecognizer:tap];

    //set delegate for topScreenTextView so that we can intercept textViewDidChange: calls and others
    [[self topScreenTextView]setDelegate:self];
    
    //set default placeholder text and color for topScreenTextView
    [self.topScreenTextView setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
    [self.topScreenTextView setTextColor:[UIColor grayColor]];
    
    // set inset to normal (keyboard is not up)
    [self.topScreenTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopScreenTextView:nil];
    [self setTopScreenView:nil];
    [self setDzeiButton:nil];
    [super viewDidUnload];
}

// called whenever a textView wants to begin editing (return YES to allow editing and NO to disallow editing and ignore the request)
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    // if text is default, then change color to normal and delete the text
    if ([self.topScreenTextView.text isEqualToString:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT]) {
        
        [self.topScreenTextView setText:@""];
        [self.topScreenTextView setTextColor:[UIColor darkTextColor]];
    }
    
    // set inset (keyboard is now up)
    [self.topScreenTextView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    // return yes (to allow editing; kb comes up)
    return YES;
}// end textViewShouldBeginEditing:

// called whenever textView is about to end editing (return YES to allow so that it resigns firstresponder and NO to keep it firstResponder)
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    // if text is left empty, then reset it to default text and light color
    if ([self.topScreenTextView.text isEqualToString:@""]) {
        
        [self.topScreenTextView setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
        [self.topScreenTextView setTextColor:[UIColor grayColor]];
    }
    
    
    // set inset to normal (keyboard is not up anymore)
    [self.topScreenTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // return yes (to allow resign first responder)
    return YES;
}// end textViewShouldEndEditing:

// disables and enables the dzei button
- (void)toggleButtonEnabled
{
    if([[self dzeiButton]isEnabled])
        [[self dzeiButton]setEnabled:NO];
    else
        [[self dzeiButton]setEnabled:YES];
}

// fades the topScreen in and out
- (IBAction)topScreenFade:(id)sender {
    
    // if the topScreen is already visible, then fade out
    if (topScreenIsVisible) {

        //fade out. Method that animates whatever is in the ^(void) block (setting alpha to zero in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:0.0];
        } completion:^(BOOL finished){}// completion block is empty in this case
         ];// if we put sthg there, it would be performed after animation is completed
        
        //disable the dzei button
        [self toggleButtonEnabled];
        // then re-enable it after a delay
        [self performSelector:@selector(toggleButtonEnabled) withObject:nil afterDelay:1.2];
        
        // don't forget to set the bool value to NO so that it can fade back in on next button tap.
        [self setTopScreenIsVisible:NO];
        
        // if topScreen is not visible, then fade it in
    } else{

        //fade in. Method that animates whatever is in the ^(void) block (setting alpha to one in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:1.0];
        } completion:^(BOOL finished){} // completion block is empty in this case
         ];                             // if we put sthg there, it would be performed after animation is completed

        //disable the dzei button
        [self toggleButtonEnabled];
        // then re-enable it after a delay
        [self performSelector:@selector(toggleButtonEnabled) withObject:nil afterDelay:1.2];
        
        // don't forget to set the bool value to YES so that it can fade back out on next button tap.
        [self setTopScreenIsVisible:YES];
    } //end if

}// end topScreenFade:


#pragma mark - Helper Methods

- (void)setCursorToEnd:(UITextView *)textView
{
	
	[textView setSelectedRange:NSMakeRange([[textView text]length], 0)];
    
}
//returns true if the two dates are in the same year
- (BOOL)isDate:(NSDate *)d1 sameYearAsDate:(NSDate *)d2
{
	
	// set up calendars and components (to compare the year parts of d1 and d2)
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit) fromDate: d1];
	NSDate *day1 = [cal dateFromComponents:components];
	
	components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit) fromDate: d2];
	NSDate *day2 = [cal dateFromComponents:components];
	
	
	//if d1 is same year as d2, return YES
	if([day1 isEqualToDate: day2]){ return YES;}
	
	// if not same year, return NO
	return NO;
    
}

//returns true if the two dates are in the same day
- (BOOL)isDate:(NSDate *)d1 sameDayAsDate:(NSDate *)d2
{
	
	// set up calendars and components (to compare the day parts of d1 and d2)
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate: d1];
	NSDate *day1 = [cal dateFromComponents:components];
	
	components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate: d2];
	NSDate *day2 = [cal dateFromComponents:components];
	
	
	//if d1 is same day as d2, return YES
	if([day1 isEqualToDate: day2]){ return YES;}
	
	// if not same day, return NO
	return NO;
}

// returns the string representation of overviewArray
- (NSString *) stringFromOverviewArray
{
    // goes through each entry and concatenates them all into one string
    NSString *overviewText=@"";
    for (NSString *entry in overviewArray) {
        overviewText = [NSString stringWithFormat:@"%@\n\n%@",overviewText,entry];
    }
    //returns that string
    return overviewText;
    
} //end stringFromOverviewArray

// adds a new entry in overviewArray with today's date
- (void)addNewEntryForToday
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //gets currentDay
	NSString *currentDayAsString = [dateFormatter stringFromDate:[NSDate date]];
	// newEntry will be simply currentDay + a return line
	NSString *newEntry = [[NSString alloc] initWithFormat:@"%@\n%@",currentDayAsString,DEFAULT_TEXT];
	
	//	//TODO add the word today instead of current date ONLY for first entry
    //		NSString *newEntry = DEFAULT_TEXT;
	
	NSInteger indexToInsert = 0;
    
    //adds the new entry as first index
    [[self overviewArray] insertObject:newEntry atIndex:indexToInsert];
	
}

// returns a string of dayOfWeek using given int
- (NSString *)dayOfWeekUsingInt: (NSInteger *)number
{
    switch ((int)number) {
        case 1:
            return @"SUN";
            break;
        case 2:
            return @"MON";
            break;
        case 3:
            return @"TUE";
            break;
        case 4:
            return @"WED";
            break;
        case 5:
            return @"THU";
            break;
        case 6:
            return @"FRI";
            break;
        case 7:
            return @"SAT";
            break;
        default:
            break;
    }
    
    // sanity check (always between 1 and 7 if using gregorian calendar); if this is reached, then
    // sthg is wrong with the calendar not being gregorian
    return @"dafuq?";
}// end dayOfWeekUsingInt:

// helper method to get filePath
- (NSString *) savefilePath
{
    // get file path (directory)
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // file name with extension
    NSString *fileWithExtension = [[NSString alloc] initWithFormat:@"overview.plist"];
    // return full path with full name
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent: fileWithExtension];
} // end saveFilePath

@end
