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

#define DEFAULT_TEXT @"Enter your J here..."
#define RESET 0

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



// whenever text is added or removed to textView (for live saving)
- (void)textViewDidChange:(UITextView *)textView
{
    //TODO CHECK if we need to do live saving. why not just save on didEndEditing? also handle all the interruptions like quit or home button
    
    [overviewArray removeObjectAtIndex:0];
    [overviewArray insertObject:[textView text] atIndex:0];
    
}

// called RIGHT before any text is inputted (to check if to allow or not). checks if it is a return
// key and disallows it if there already is a return before or after cursor (to disallow double
// returns)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    // if insertion point (no highlighted text)
    if (range.length ==0) {
        // gets location of cursor
        NSInteger cursorIndex = range.location;
        
        // if user types return
        if ([text isEqualToString:@"\n"]){
			
            //check if there is a return before cursor (short circuit AND to make sure cursor
            // isn't in FIRST position, index 0; cursorIndex-1 would then give negative number -> error)
            // if there is a return before cursor, don't change the text (i.e. don't let the
            // \n go through)
            if( cursorIndex > 0 && [textView.text characterAtIndex:cursorIndex-1] == '\n')
            {
                return  NO;
				
				//check if there is a return after cursor (short circuit AND to make sure cursor isn't
				// in LAST position; cursorIndex would then be out of bounds if we try to get char)
				// if there is a return after cursor, don't let it through (return NO)
            } else if(cursorIndex < textView.text.length && [textView.text characterAtIndex:cursorIndex] == '\n') {
                return NO;
				
				// if return typed at beginning of entry, also don't allow \n to go through
            }else if(range.location==0)
                return NO;
        }
        
		// if highlighted text then pressed return, don't allow /n to go through
    }else if(range.length >0){
        if ([text rangeOfString:@"\n"].length != 0)
            return NO;
    }
    
    // BUG, user can enter more than one return if they use highlighting in some way (range.length>0)
    // or when copying and pasting a double return... negligible
    
	
    //	lastCursorLength = range.length;
    //	lastCursorLocation = range.location;
	
    // in normal cases, allow the textView to be changed...
    return YES;
}


// when user done editing
// saves the top entry to the overviewArray (plus prefixing date meta data)
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    UITextView *tv = [self topScreenTextView];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
    //gets text from top cell
    NSString *text = [tv text];
    // gets the date
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    // the newEntry will be date + text with a return line in between
    NSString *newEntry = [[NSString alloc]initWithFormat:@"%@\n%@",date,text];
    
    // saves the top tableView cell into the array
    [overviewArray replaceObjectAtIndex:0 withObject:newEntry] ;
	
    // saves the array to file
    [self saveDataToFile];
    
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


#pragma mark - Saving & loading (file IO) methods

// performs all data updating necessary when loading (reads from files and writes to files)
- (void) populateArrayWithData
{
	
    // populate the overviewArray from file data
    
    // if readData returns sthg (if file is there)
    if ([self readDataFromFile] != nil) {
		[self setOverviewArray:[self readDataFromFile]];
		
		
		//no need since it's always called when entering background state
		//		//first, dismiss keyboard properly (in case it was already up)
		//
		//		[[self dismissKeyBoardButton] setEnabled:NO];
		//		// dismiss keyboard in case it was up
		//		[self dismissKeyboardButton:nil];
		
		
		//create dateFormatter
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		// set date format
		[dateFormatter setDateFormat:@"dd-MM-yyyy"];
		
		//read in date from last entry
		
		NSString *lastEntryString = [[self overviewArray] objectAtIndex:0];
		// the range needed for the date (first line)
		NSRange rangeOfDate = [lastEntryString lineRangeForRange:NSMakeRange(0,1) ];
		NSString *lastEntryDateAsString = [lastEntryString substringWithRange: rangeOfDate];
		NSString *lastEntryText = [lastEntryString substringFromIndex:rangeOfDate.length];
		
		// REMOVE RETURN CARRIAGE FROM DATE!!!
		lastEntryDateAsString = [lastEntryDateAsString substringToIndex:lastEntryDateAsString.length -1];
		
		NSDate *lastEntryDate = [dateFormatter dateFromString:lastEntryDateAsString];
		
		//now, we compare lastEntryDate to today's date and see if they are not the same day
		// if they are not, we will create a new entry for today
		if(![self isDate:lastEntryDate sameDayAsDate:[NSDate date]]){
			
			
			//first, check if the last entry is blank or not. If it is, remove that entry (since it's blank)
			if (lastEntryText == nil || [lastEntryText isEqualToString:@""] || [lastEntryText isEqualToString:DEFAULT_TEXT]) [overviewArray removeObjectAtIndex:0];
			
			// make a new entry because today is a new day
			[self addNewEntryForToday];
			
			// save to file
			[self saveDataToFile];
			
			
		}// end if(not the same day)
		
		//else if file is missing
    }else {
        // add a new entry
        [self addNewEntryForToday];
        // and save to file
        [self saveDataToFile];
    }
	
	
	// FOR TESTING (resets all values)
	if (RESET) {
		overviewArray = [[NSMutableArray alloc]init];
		[self saveDataToFile];
	}
	
}// end performUpdateOnLoad

// saves data from text field into file with given name
- (void) saveDataToFile
{
    // new array
    NSMutableArray *dataToSave;
    
    //TODO (new line of code here) save the overviewArray to overviewFile
    dataToSave = [self overviewArray];
	
    // else, there is a problem, don't proceed.
    
    //writes text data to file
    [dataToSave writeToFile:[self savefilePath] atomically:YES];
    
}// end saveData

// returns NSMutableArray of file contents
// TODO check for nil returns when calling this method
- (NSMutableArray *) readDataFromFile
{
    
    //if file doesn't exist, return
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self savefilePath]]) {
        return nil;
    }
    
    // new array
    NSMutableArray *dataToLoad;
    // read in file
    dataToLoad = [[NSMutableArray alloc] initWithContentsOfFile: [self savefilePath] ];
    
    // check if file is not empty
    if([dataToLoad count] < 1)
    {
        // return empty array
        return nil;
    }
    
    return dataToLoad;
}// end readDataFromFileName


#pragma mark - Helper Methods

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
