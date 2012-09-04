//
//  ViewController.m
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>

@interface ViewController()

@end

@implementation ViewController

@synthesize overviewArray;
@synthesize overviewTableView;
@synthesize dismissKeyBoardButton;
@synthesize infoView;
@synthesize optionsButton;
@synthesize loupeGestureDetector;

#pragma mark - constants for label frames and sizes usw.

#define RESET 0

#define CELL_WIDTH 320.0
#define MAX_CELL_HEIGHT 10000.0
#define MAX_TODAY_CELL_HEIGHT 300.0
#define MIN_CELL_HEIGHT 44.0

#define DAYNAME_TAG 1
#define DATE_TAG 2
#define TEXT_TAG 3

#define DAYNAME_X_OFFSET 110.0
#define DAYNAME_Y_OFFSET 34.0
#define DAYNAME_WIDTH 100.0
#define DAYNAME_HEIGHT 44.0

#define DATE_X_OFFSET 110.0
#define DATE_Y_OFFSET 10.0
#define DATE_WIDTH 130.0
#define DATE_HEIGHT 24.0

#define TEXT_X_OFFSET 160.0
#define TEXT_WIDTH 100.0
//y margin on top of text AND at bottom (so twice as this much pixels total)
#define TEXT_Y_OFFSET 20.0

#define DAYNAME_FONT_SIZE 18.0
#define TEXT_FONT_SIZE 18.0
#define DATE_FONT_SIZE 18.0


int lastCursorLocation;
int lastCursorLength;
bool isFirstTap;

NSString *DEFAULT_TEXT = @"Enter your J here...";
#pragma mark - UITableView protocol & other methods

//UITableViewDataSource protocol method
// responsible for creating each cell within the tableView
// calls getCellContentView to create cell content from scratch or dequeues it (reuses it)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the cell's entry string (that day's date+log)
    NSString *entryString = [overviewArray objectAtIndex:[indexPath row]];
    
    // the range needed for the date (first line)
    NSRange rangeOfDate = [entryString lineRangeForRange:NSMakeRange(0,1) ];
    
    // extracted date from entryString
    NSString *dateAsString = [entryString substringWithRange: rangeOfDate];
	
    // gets the (log) text from entry (by taking substring of entryString from point where dateAsString finished and onwards)
    NSString *textString = [entryString substringFromIndex:rangeOfDate.length];    
    
    // the entry's cell is initialized (gets reusable cell if possible)
    UITableViewCell *cell;
	
    // reuse cell with dequeueing if possible
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // if not possible, make cell from scratch
    if(cell == nil)
        cell = [self getCellContentViewWithCellIdentifier:@"cell" AtIndexPath:indexPath];
    
    // all of the cell's subviews are retrieved (using tags) so their text can be changed
    UILabel *daynameLabel = (UILabel *)[cell viewWithTag:DAYNAME_TAG];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:DATE_TAG];
    UITextView *textView = (UITextView *)[cell viewWithTag:TEXT_TAG];    
	
    
    // get the dayOfTheWeek and set daynameLabel text to it
    
    //create dateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //takes off last character in dateAsString (the return carriage)
    dateAsString = [dateAsString substringToIndex:[dateAsString length] -1];
    // obtain date from string using dateFormatter
    NSDate *date = [dateFormatter dateFromString:dateAsString];
	
    // sets calendar and components to get weekday
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [cal components:NSWeekdayCalendarUnit fromDate: date];
    
    // gets the weekday as an int using components
    NSInteger *dayOfWeekAsInt = (NSInteger *)[comp weekday];
    // gets the weekday string from helper method
    daynameLabel.text =  [self dayOfWeekUsingInt:dayOfWeekAsInt];
	
	// this variable will tell whether to delete year part in dateLabel or not
	int numberOfCharsToDeleteAtEndOfDate = 5;
	
	
	    textView.text = textString;
	
	// if cell's date is today, then set text to TODAY and change colors and set it scrollable
	if ([self isDate:date sameDayAsDate:[NSDate date]]) {
		daynameLabel.text = @"TODAY";
		
		[dateLabel setTextColor:[UIColor redColor]];
		[daynameLabel setTextColor:[UIColor redColor]];
		
		[textView setScrollEnabled:YES];
		
		//TODO how does this refresh? need to refresh this after textViewChange or edit
		//gray out the default text 
		if ([[textView text] isEqualToString:DEFAULT_TEXT]) {
			[textView setTextColor:[UIColor grayColor]];
		}else {
			[textView setTextColor:[UIColor redColor]];
		}
		
	// if it's not today, then keep it black and non-scrollable AND check if it's a diff year (to keep the year part)
	}else {
		[dateLabel setTextColor:[UIColor blackColor]];
		[daynameLabel setTextColor:[UIColor blackColor]];
		[textView setTextColor:[UIColor blackColor]];
		[textView setScrollEnabled:NO];
		
		//check if the cell is NOT in the same year as today's date
		if(![self isDate:date sameYearAsDate:[NSDate date]])
		{
			numberOfCharsToDeleteAtEndOfDate = 0;
		}
	}
	
	
    // now, change dateLabel text
    
    //first, get the date without the year (excludes last 5 chars) UNLESS we're in a diff year
    NSString *dateWithoutYearAsString = [dateAsString substringToIndex:[dateAsString length] - numberOfCharsToDeleteAtEndOfDate];
    //sets the dateLabel text
    dateLabel.text = dateWithoutYearAsString;
	
	
    // textView rowHeight is calculated and set AGAIN in case of dequeueing
        CGFloat rowHeight = [self tableView:overviewTableView heightForRowAtIndexPath:indexPath];
    //we set the frame (in case we are dequeueing cell)
    CGRect rect = CGRectMake(TEXT_X_OFFSET, TEXT_Y_OFFSET, TEXT_WIDTH, rowHeight - TEXT_Y_OFFSET*2);
    [textView setFrame:rect];
    // finally, change textLabel text
    textView.text = textString;
    
    // return that cell
    return cell;
    
} // end tableView:cellForRowAtIndexPath:


// gets UITableViewCell contentView (basically creates each cell from scratch here)
- (UITableViewCell *) getCellContentViewWithCellIdentifier: (NSString *) cellIdentifier AtIndexPath: (NSIndexPath *) indexPath
{
    // creates cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell" ];
    
    // set the whole cell to opaque (for performance issues when scrolling)
    [cell setOpaque:YES];
    [cell.contentView setOpaque:YES];
	
    //TODO consider setting each UILabel below as opaque also...
    
    // disable selection of table cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
    CGRect rect;
	
    // TODO label tweaking below
    
    // the DAYNAME label is created and configured    
    // Create a dayname label for the cell and add to cell's contentView as a subview
    UILabel *daynameLabel;
	
	rect = CGRectMake(DAYNAME_X_OFFSET - DAYNAME_WIDTH, DAYNAME_Y_OFFSET, DAYNAME_WIDTH, DAYNAME_HEIGHT);
	daynameLabel = [[UILabel alloc] initWithFrame:rect];
	[daynameLabel setTextAlignment:UITextAlignmentRight];
	[daynameLabel setLineBreakMode:UILineBreakModeClip];
	
	daynameLabel.tag = DAYNAME_TAG;
	daynameLabel.font = [UIFont boldSystemFontOfSize:DAYNAME_FONT_SIZE];
    daynameLabel.backgroundColor = [UIColor whiteColor];
	[daynameLabel setOpaque:YES];
	
	// add the dayname label as a subview to the cell
    [cell.contentView addSubview:daynameLabel];
	
    // now, the DATE label is created and configured
    
    UILabel *dateLabel;
    
	// the x position is configured for rightAlignment
	rect = CGRectMake(DATE_X_OFFSET- DATE_WIDTH, DATE_Y_OFFSET, DATE_WIDTH, DATE_HEIGHT);
	dateLabel = [[UILabel alloc] initWithFrame:rect];
	
	[dateLabel setTextAlignment:UITextAlignmentRight];
	[dateLabel setLineBreakMode:UILineBreakModeClip];
	dateLabel.tag = DATE_TAG;
	dateLabel.font = [UIFont boldSystemFontOfSize:DATE_FONT_SIZE];
    dateLabel.backgroundColor = [UIColor whiteColor];
	[dateLabel setOpaque:YES];
	
    // add the date label as a subview to the cell
    [cell.contentView addSubview:dateLabel];
    
	
    // now the actual textView (to hold user-entered text) is created and configured
    UITextView *textView;
	
	// get the rowHeight dynamically
    CGFloat rowHeight = [self tableView:[self overviewTableView] heightForRowAtIndexPath:indexPath];
	
	rect = CGRectMake(TEXT_X_OFFSET, TEXT_Y_OFFSET, TEXT_WIDTH, rowHeight - TEXT_Y_OFFSET*2);
	textView = [[UITextView alloc] initWithFrame:rect];
    //    textLabel.textAlignment = UITextAlignmentCenter;
	textView.tag = TEXT_TAG;
	textView.font = [UIFont boldSystemFontOfSize:TEXT_FONT_SIZE];
    textView.backgroundColor = [UIColor whiteColor];
    textView.delegate = self;
    [textView setUserInteractionEnabled:YES];
	[textView setOpaque:YES];
	// REMOVES the inner margins inside the textView (fixes dynamic height)
	[textView setContentInset:UIEdgeInsetsMake(-8,-8,-8,-8)];
	
	//    textView.scrollEnabled = NO;
	
    // add the text view as a subview to the cell
    [cell.contentView addSubview:textView];
    
    // now that the cell has the 3 subviews ready, return it
    return cell;
	
}// end getCellContentViewWithCellIdentifier:AtIndexPath:


//UITableViewDataSource protocol method
// returns the number of rows (cells)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [overviewArray count];
}

//UITableViewDelegate protocol method
// TODO dynamic row height here
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the text for the cell's entry
    NSString *text = [overviewArray objectAtIndex:[indexPath row]];
	
    // set up a constraint
    CGSize constraint = CGSizeMake(TEXT_WIDTH, MAX_CELL_HEIGHT);
	
	// set today cell max height (less than other heights)
	if ([indexPath row] == 0) {
		constraint = CGSizeMake(TEXT_WIDTH, MAX_TODAY_CELL_HEIGHT);
	}	
	
    //TODO don't forget to use same font here as used in cell
    // calculated size of the text label using the constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeCharacterWrap];

	
    // gets the rowHeight (either this or the minimum)
    CGFloat rowHeight = MAX(size.height, MIN_CELL_HEIGHT);

    // returns it (also adds margins on top and bottom)
    return rowHeight + (TEXT_Y_OFFSET*2);    
}// end

// informs (all) tableviews that they should have one section only...
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// detects when view (tableView in this case) is dragged and dismisses keyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboardButton:nil];
}

#pragma mark - UITextView delegate methods

// called right when a textView is tapped
// decides whether user is allowed to edit the textView (only allows top entry to be edited)
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{        
    // get indexPath of tapped textView cell
    NSIndexPath *indexPath = [overviewTableView indexPathForCell: (UITableViewCell *)[[textView superview] superview] ];
	
    // if tapped textView is top entry, then allow it to be edited
    if ([indexPath row] == 0) {
		[textView setSelectedRange:NSMakeRange(lastCursorLocation, lastCursorLength)];

		//TODO TEST BELOW
		// adds a margin on bottom of tableView so that keyboard does not cover the cursor...
		[self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 200, 0)];
        return YES;
    }
    
    // in case it wasn't the top entry that was tapped, dismiss the keyboard
    [self dismissKeyboardButton:nil];
    // and don't allow textView to be edited
    return NO;
}

// called when textView begins editing
//enables the dismissKeyboardButton and adds inset to table view (so that keyboard
// doesn't cover the cursor)
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	
	
	
    [[self dismissKeyBoardButton] setEnabled:YES];
}

// called right before keyboard is dismissed (to save current cursor location)
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if (!isFirstTap) {
		lastCursorLocation = textView.selectedRange.location;
		lastCursorLength = textView.selectedRange.length;
	} else {
//		isFirstTap=NO;
	}

    return YES;
}

// when user done editing (after dismissKeyboardButton:)
// saves the top entry to the overviewArray and disables the dismissKeyboardButton
- (void)textViewDidEndEditing:(UITextView *)textView
{
	NSLog(@"dafuuuuq?");
    // disable the button
    [[self dismissKeyBoardButton] setEnabled:NO];
    
    // gets the top cell
    UITableViewCell *cell = [overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ];
    // gets the textView in the top cell
    UITextView *tv = (UITextView *)[cell viewWithTag:TEXT_TAG];
    
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
    
    // fixes table view inset (keyboard is now down, return inset to normal)
    [self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
	
    // update the table view entries
    [overviewTableView reloadData];
	
//	[textView scrollRangeToVisible:NSMakeRange(lastCursorLocation, lastCursorLength)];
// also set the cursor position to last known one
// TODO bouncing bug fix here???
//	[textView setSelectedRange:NSMakeRange(lastCursorLocation, lastCursorLength)];

	
}
//called whenever cursor is moved or when user taps textView or when edited
//checks if this is firstTap to set cursor at end.
- (void)textViewDidChangeSelection:(UITextView *)textView
{
	NSLog(@"textView DID CHANGE!");
	//TODO fix bug when user tries to select text by holding (when firstTap)
	if (isFirstTap) {
		[self performSelector:@selector(setCursorToEnd:) withObject:textView afterDelay:0.01];
		isFirstTap=NO;
	}
}

// whenever text is added or removed to textView (for live resizing)
- (void)textViewDidChange:(UITextView *)textView
{
    // gets indexPath for top entry
    NSIndexPath *ipForFirstCell = [NSIndexPath indexPathForRow:0 inSection:0];
	
    // update the table view (but this dismisses keyboard)
    [self.overviewTableView reloadData];
    // call the keyboard back up
    [[[[overviewTableView cellForRowAtIndexPath:ipForFirstCell] contentView] viewWithTag:TEXT_TAG] becomeFirstResponder];
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

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//	if (scrollView ) {
//		<#statements#>
//	}
//}

#pragma mark - Buttons and misc. event methods

// actually dismisses keyboard (called within many other methods); causes textViewDidEndEditing to be called
- (IBAction)dismissKeyboardButton:(id)sender {
    
    [(UITextView *)[[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TEXT_TAG] resignFirstResponder];
	isFirstTap=YES;
}

// animates the infoView fading out (using block animations)
- (void)infoPageFadeOut
{
	[overviewTableView setOpaque:YES];

	[UIView animateWithDuration:1 animations:^(void){
		
		[infoView setAlpha:0.0];
		
	} completion:^(BOOL finished){
		if (finished) {
			[UIView animateWithDuration:1 animations:^(void){
				
				[overviewTableView setAlpha:1.0];
				[optionsButton setAlpha:1.0];
				
			}  ];
		}
	}];
	

}

// animate the infoView fading in
- (void)infoPageFadeIn
{
	[overviewTableView setOpaque:NO];
	
	[UIView animateWithDuration:1 animations:^(void){
		
		[overviewTableView setAlpha:0.0];
		[optionsButton setAlpha:0.0];
		
	} completion:^(BOOL finished){
		if (finished) {
			[UIView animateWithDuration:1 animations:^(void){
				

				[infoView setAlpha:1.0];
				
			}  ];
		}
	}];
	
}


# pragma mark - UIActionSheet and MFMail methods

// when actionSheet buttons are pressed
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    switch (buttonIndex) {
            
            // if email button
        case 0:
            
            // if mail is set-up, then create mailViewController and fill in details to send email
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailman = [[MFMailComposeViewController alloc]init];
                mailman.mailComposeDelegate = self;
                [mailman setSubject:@"Your work journal"];
                NSString *messageString = [NSString stringWithFormat:@"Below is a copy of your journal.\n%@",[self stringFromOverviewArray]];
                [mailman setMessageBody: messageString isHTML:NO];
                [self presentModalViewController:mailman animated:YES];
                
				// if mail is not set up on device, display an alert
            }else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Device is not configured for sending emails. Please configure your email options in the Mail app." delegate:nil cancelButtonTitle:@"OK, my bad" otherButtonTitles: nil];
                [alert show];
                
            }
            break;
            
            // if info button
        case 1:
            //fade in the info page
            [self infoPageFadeIn];
            break;
    }// end switch
    
}// end actionSheet:clickedButtonAtIndex:


// MFMailComposeViewController delegate protocol method.
// called when an MFMailComposeViewController is dismissed
- (void)mailComposeController:(MFMailComposeViewController *)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //TODO add alerts for results of the email sending or do stuff when user cancels or saves draft
    
    [self dismissModalViewControllerAnimated:YES];
}

// brings up option menu
// TODO tweak string names and options
- (IBAction)optionsButton:(id)sender {
    
    // create action sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Email", @"Info", nil];
    // show action sheet
    [actionSheet showInView:self.view];
    
}// end optionsButton

#pragma mark - Helper Methods

- (void)setCursorToEnd:(UITextView *)textView
{

	NSLog(@"this is the state of loupeDetector: %@", [loupeGestureDetector state]);
	
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

#pragma mark - View methods & misc.
// called every time the view loads (usually upon app launch or unminimize)
- (void)viewDidLoad
{
	
    [super viewDidLoad];
	
	NSLog(@"inViewDidLoad!");
	
    // initializes overviewArray to an empty array
    overviewArray = [[NSMutableArray alloc] init];
	
    // loads data into overview array
    [self populateArrayWithData];
    
	
    //NOTE: all views and subviews are created in the nib. None are created within the code. Only the tableViewCells are created in code.
	
    // table view properties set here
    [overviewTableView setBounces:YES];
    [overviewTableView setAlwaysBounceVertical:YES];
    [overviewTableView setDelaysContentTouches:YES];
    [overviewTableView setScrollEnabled:YES];
	[overviewTableView setOpaque:YES];
    
    //VERY IMPORTANT (so that infoView can be tapped)
    [self.infoView setUserInteractionEnabled:YES];
	[self.infoView setFrame:CGRectMake(0, 0, infoView.frame.size.width, infoView.frame.size.height)];
	[self.infoView setAlpha:0.0];
	
	
    // set up (tap recognizer for the infoView)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(infoPageFadeOut)];
    [tap setNumberOfTapsRequired:1];
    [self.infoView addGestureRecognizer:tap];
	
	
    // set up (tap rec for overviewTableView)
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboardButton:)];
    [tap setNumberOfTapsRequired:1];
    [self.overviewTableView addGestureRecognizer:tap];
	
    // turn off selection for table view
    overviewTableView.allowsSelection=NO;
	
	// set the insets back to normal (huge bottom inset was there when keyboard was up)
    [self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
	
    // finally, reload the tableView (reloads cells and their subviews usw.)    
    [overviewTableView reloadData];
    
	// TODO note that this is only called once (viewDidLoad). what if day changes?
	// adds the longPress gesture recognizer to the first cell
	UITextView *topTextView = (UITextView *) [[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TEXT_TAG];
	loupeGestureDetector = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:nil];
	[topTextView addGestureRecognizer:loupeGestureDetector];
	
	
	isFirstTap=YES;
	
} // end viewDidLoad

- (void)viewDidUnload
{		
    [self setOverviewArray:nil];
    [self setDismissKeyBoardButton:nil];
    [self setOverviewTableView:nil];
    [self setInfoView:nil];
	
	[self setOptionsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
