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

#pragma mark - Constants

#define TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT @"Enter today's journal here..."

#pragma mark - UIView life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    overviewArray = [[NSMutableArray alloc] init];
    
    // before reading in data from file, check if user prefs is set to wipe all and act accordingly...
    [self checkWipeAllOption];

    // populate overviewArray and sets TopScreenTV text
    [self populateArrayWithData];
    
    // set overviewTextView text to values from overviewArray (skips first entry since it's already in topScreenTV)
    [self loadOverviewTextViewText];
    
    [self setTopScreenIsVisible:YES];
    
    // set up (tap recognizer for the infoView)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setNumberOfTapsRequired:1];
    [self.topScreenView addGestureRecognizer:tap];

    //set delegate for topScreenTextView so that we can intercept textViewDidChange: calls and others
    [[self topScreenTextView]setDelegate:self];

    [self.topScreenTextView setReturnKeyType:UIReturnKeyDone];
    
    // set inset to normal (keyboard is not up)
    [self.topScreenTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];

    // disables tint change when button is pressed (the other button has this set in xib)
    [self.topDzeiButton setAdjustsImageWhenHighlighted:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopScreenTextView:nil];
    [self setTopScreenView:nil];
    [self setTopDzeiButton:nil];
    [self setOverviewTextView:nil];
    [super viewDidUnload];
}


#pragma mark - textViewDelegate methods

// disables return completely and implements "done" functionality
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
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
			if (lastEntryText == nil || [lastEntryText isEqualToString:@""] || [lastEntryText isEqualToString:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT])
                [overviewArray removeObjectAtIndex:0];
			
			// make a new entry because today is a new day
			[self addNewEntryForToday];
			
            //set default placeholder text and color for topScreenTextView
            [self.topScreenTextView setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
            [self.topScreenTextView setTextColor:[UIColor grayColor]];
            
			// save to file
			[self saveDataToFile];
			
			
		}// end if(not the same day)
		// else (if it is the same day)
        else{
            
            // set TopScreenTV text to first entry in overviewArray (excluding date metadata)
            [[self topScreenTextView] setText:[self entryStringWithoutDateMetadata:0]];
        }
    
        
		//else if file is missing
    }else {
        // add a new entry
        [self addNewEntryForToday];
        // and save to file
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


// similar to stringFromOverviewArray except it skips first entry and takes result and sets it to overviewTextView
- (void) loadOverviewTextViewText{
    
    // goes through each entry and concatenates them all into one string
    NSString *overviewText=@"";
    for (int i=1;i<overviewArray.count;i++) {
        overviewText = [NSString stringWithFormat:@"%@\n\n%@",overviewText,[overviewArray objectAtIndex:i]];
    }

    [[self overviewTextView] setText:overviewText];
    
}

// adds a new entry in overviewArray with today's date
- (void)addNewEntryForToday
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //gets currentDay
	NSString *currentDayAsString = [dateFormatter stringFromDate:[NSDate date]];
	// newEntry will be simply currentDay + a return line
	NSString *newEntry = [[NSString alloc] initWithFormat:@"%@\n%@",currentDayAsString,TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
	
	//	//TODO add the word today instead of current date ONLY for first entry
    //		NSString *newEntry = DEFAULT_TEXT;
	
	NSInteger indexToInsert = 0;
    
    
    //adds the new entry as first index
    [[self overviewArray] insertObject:newEntry atIndex:indexToInsert];
	
}

// helper method that returns filePath for saving entries
- (NSString *) savefilePath
{
    // get file path (directory)
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // file name with extension
    NSString *fileWithExtension = [[NSString alloc] initWithFormat:@"overview.plist"];
    // return full path with full name
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent: fileWithExtension];
} // end saveFilePath

//checks if user pref wipe_all_data is set TRUE
- (void) checkWipeAllOption
{
    // if wipe all is ON
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wipe_all_data"]) {
        
        // first, reset the preference wipe_all_data back to off so we don't keep rewiping every time (user must set it back to on again)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wipe_all_data"];
        
        // synchronizes the current userdefaults (in this scope) and the one in plist file
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        // now, actually wipe all data (by simply writing over file with the currently empty OverviewArray)
		[self saveDataToFile];
        
        // also, set the topScreenTextView text to default (wipe that also)
        [[self topScreenTextView] setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
        
    } // end if
    
} // end checkWipeAllOption

// returns the entry's string text and excludes the first line (date metadata)
-(NSString *)entryStringWithoutDateMetadata: (int) index
{
    // the entire entry string (including date metadata)
    NSString *entryString = [overviewArray objectAtIndex: index];
    
    // the range needed for the date (the first line holds the date)
    NSRange rangeOfDate = [entryString lineRangeForRange:NSMakeRange(0,1) ];

    // extracts the text from entry (and excluding date metadata)
    NSString *textString = [entryString substringFromIndex:rangeOfDate.length];
    
    return textString;
    
}// end entryStringWithoutDateMetadata

#pragma mark - user input event methods

// fades the topScreen in and out
- (IBAction)topScreenFade:(id)sender {
    
    // if the topScreen is already visible, then fade out
    if (topScreenIsVisible) {
        
        //fade out. Method that animates whatever is in the ^(void) block (setting alpha to zero in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:0.0];
            
            [[self topDzeiButton] setAlpha:0.0];
            
        } completion:^(BOOL finished){}// completion block is empty in this case
         ];// if we put sthg there, it would be performed after animation is completed
        
        // don't forget to set the bool value to NO so that it can fade back in on next button tap.
        [self setTopScreenIsVisible:NO];
        
        // if topScreen is not visible, then fade it in
    } else{
        
        //fade in. Method that animates whatever is in the ^(void) block (setting alpha to one in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:1.0];
            
            [[self topDzeiButton] setAlpha:1.0];

        } completion:^(BOOL finished){} // completion block is empty in this case
         ];                             // if we put sthg there, it would be performed after animation is completed
        
        // don't forget to set the bool value to YES so that it can fade back out on next button tap.
        [self setTopScreenIsVisible:YES];
    } //end if
    
}// end topScreenFade:

- (void)dismissKeyboard
{
    [self.topScreenTextView resignFirstResponder];
}

#pragma mark - Mail methods

- (IBAction)sendMail:(id)sender {
    
    // if mail is set-up, then create mailViewController and fill in details to send email
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailman = [[MFMailComposeViewController alloc]init];
        mailman.mailComposeDelegate = self;
        [mailman setSubject:@"Your J exported data"];
        NSString *messageString = [NSString stringWithFormat:@"Your J exported data:\n%@",[self stringFromOverviewArray]];
        [mailman setMessageBody: messageString isHTML:NO];
        [self presentViewController:mailman animated:YES completion:nil];
        
        // if mail is not set up on device, display an alert
    }else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Device is not configured for sending emails. Please configure your email options in the Mail app." delegate:nil cancelButtonTitle:@"OK, my bad..." otherButtonTitles: nil];
        [alert show];
        
    }

}

// MFMailComposeViewController delegate protocol method.
// called when an MFMailComposeViewController is dismissed
- (void)mailComposeController:(MFMailComposeViewController *)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //TODO add alerts for results of the email sending or do stuff when user cancels or saves draft
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
