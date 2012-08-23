//
//  ViewController.m
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import "ViewController.h"

#import "QuartzCore/QuartzCore.h"

@interface ViewController()

@end

@implementation ViewController

@synthesize scrollView;
@synthesize todayTextView;
@synthesize overviewTextView;
@synthesize overviewArray;
@synthesize overviewTableView;
@synthesize dismissKeyBoardButton;
@synthesize lastCursorLength;
@synthesize lastCursorLocation;
@synthesize textBeingEdited;



#pragma mark - constants for label frames and sizes usw.

#define CELL_WIDTH 320.0
#define MAX_CELL_HEIGHT 2000.0
#define MIN_CELL_HEIGHT 44.0

#define DAYNAME_TAG 1
#define DATE_TAG 2
#define TEXT_TAG 3
#define BUTTON_TAG 4

#define DAYNAME_OFFSET 10.0
#define DAYNAME_WIDTH 100.0

#define DATE_OFFSET 10.0
#define DATE_WIDTH 90.0

#define TEXT_OFFSET 160.0
#define TEXT_WIDTH 100.0
#define TEXT_MARGIN 20.0

#define DAYNAME_FONT_SIZE 18.0
#define TEXT_FONT_SIZE 18.0
#define DATE_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0


#pragma mark - UITableView protocol methods

//UITableViewDataSource protocol method
// responsible for making each cell within the tableView
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

    //TODO dequeueing is currently turned OFF! uncomment two lines below to turn it ON!
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
        cell = [self getCellContentViewWithCellIdentifier:@"cell" AtIndexPath:indexPath];
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // all label views are retrieved so their text can be changed
    UILabel *daynameLabel = (UILabel *)[cell viewWithTag:DAYNAME_TAG];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:DATE_TAG];
    UITextView *textLabel = (UITextView *)[cell viewWithTag:TEXT_TAG];
//    UIButton *doneButton= (UIButton *)[cell viewWithTag:BUTTON_TAG];
    
    //TODO (new bug-fix code here) we set the frame (in case we are dequeueing cell)
    CGFloat rowHeight = [self tableView:[self overviewTableView] heightForRowAtIndexPath:indexPath];
    
//    [cell setFrame:CGRectMake(0, 0, <#CGFloat width#>, <#CGFloat height#>)];
    
    
//    CGFloat rowHeight = 50.0;
//    NSLog(@"in cellForRowAtIndexPath height is: %f", rowHeight);
    CGRect rect = CGRectMake(TEXT_OFFSET, 0, TEXT_WIDTH, rowHeight);
    [textLabel setFrame:rect];
    
    //TODO for debugging (to check frame borders)
    [[textLabel layer] setBorderWidth:2.0f];
    
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

    
    // now, change dateLabel text
    
    //first, get the date without the year (excludes last 5 chars)
    NSString *dateWithoutYearAsString = [dateAsString substringToIndex:[dateAsString length] - 5];
//    NSString *dateWithoutYearAsString = dateAsString;
    //sets the dateLabel text
    dateLabel.text = dateWithoutYearAsString;
    
    
    // finally, change textLabel text
    textLabel.text = textString;
    
//    [textLabel setFrame:CGRectMake(TEXT_OFFSET, 0, TEXT_WIDTH, rowHeight)];
    
    // TODO for debugging (tells when each cell is recreated or re-initialized)
//    NSLog(@"making cell number: %i", [indexPath row]);

    
    // return that cell
    return cell;
    
} // end tableView:cellForRowAtIndexPath:

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
//    CGSize constraint = CGSizeMake(CELL_WIDTH - (TEXT_MARGIN*2), MAX_CELL_HEIGHT);
    CGSize constraint = CGSizeMake(TEXT_WIDTH, MAX_CELL_HEIGHT);
    //    rect = CGRectMake(TEXT_OFFSET, (rowHeight - LABEL_HEIGHT) / 2.0, TEXT_WIDTH, rowHeight);

    //TODO don't forget to use same font here as used in cell
    // calculated size of the text label
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    // gets the rowHeight (either this or the minimum)
    CGFloat rowHeight = MAX(size.height, MIN_CELL_HEIGHT);
    
    // returns it (also adds margins on top and bottom)
    return rowHeight + (TEXT_MARGIN*2);    
//    return 50.0;
}

// informs (all) tableviews that they should have one section only...
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([indexPath row] != 0) {
//        [self dismissKeyboardButton:nil];
//        return nil;
//    }
//    
//    [[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:TEXT_TAG] becomeFirstResponder];
//    
//    return nil;
//}
#pragma mark - UITextView delegate methods

// when user done editing
// saves the todaytext and disables the dismissKeyboardButton
- (void)textViewDidEndEditing:(UITextView *)textView
{
    // save today text into today file
//    [self saveDataInFileName:@"today"];
//    textViewBeingEdited = NO;
    

//    NSLog(@"didEndEditing!");
    
    // disable the button (to allow swiping scrolling)
    [[self dismissKeyBoardButton] setEnabled:NO];
    
    
    UITableViewCell *cell = [overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ];
    UITextView *tv = (UITextView *)[cell viewWithTag:TEXT_TAG];
    

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];

    
    NSString *text = [tv text];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];    
    NSString *newEntry = [[NSString alloc]initWithFormat:@"%@\r%@",date,text];
    
    [overviewArray replaceObjectAtIndex:0 withObject:newEntry] ;
    
    [self saveData];
    
    [self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];


//        [overviewTableView reloadData];
    [overviewTableView reloadData];
    
//    self.textViewBeingEditedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{        
//    NSLog([[[[textView superview] superview] superview]description]);
    NSIndexPath *ip = [overviewTableView indexPathForCell: (UITableViewCell *)[[textView superview] superview] ];
    if ([ip row] == 0) {

        [textView setSelectedRange:NSMakeRange(lastCursorLocation, lastCursorLength)];
        
//        if(!textBeingEdited) textBeingEdited=YES;
        
        return YES;
    }
    
    [self dismissKeyboardButton:nil];
    return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
//    if(!textBeingEdited){
        self.lastCursorLocation = textView.selectedRange.location;
        self.lastCursorLength = textView.selectedRange.length;
//    }
    
    return YES;
}

//enables the dismissKeyboardButton only while editing
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
//    textViewBeingEdited = YES;
    
//    [[self overviewTableView] reloadData];

    [[self dismissKeyBoardButton] setEnabled:YES];

    // adds a margin on bottom of tableView so that keyboard does not cover the cursor...
    [self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 200, 0)];
    
    
    
//    [self.view bringSubviewToFront:dismissKeyBoardButton];
//    [[self view] bringSubviewToFront:textView];
    
}


// whenever text is added or removed to textView (resize its cell)
- (void)textViewDidChange:(UITextView *)textView
{
//    [overviewTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//    [overviewTableView reloadData];
    //    [[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] becomeFirstResponder];
    //    [UIView setAnimationsEnabled:YES];
    
    //TODO beware of when selectedRange.length is not 0

//    NSString *lastTwoChars;
    
//    if(textView.text.length>2){
//        
//        
//        
//        
//        
//        lastTwoChars = [textView.text substringWithRange:NSMakeRange(textView.selectedRange.location -2, 2)];
//        
//        if ([lastTwoChars isEqualToString:@"\n\n"]){
//            
//            [textView setText:         [textView.text stringByReplacingCharactersInRange:NSMakeRange(textView.selectedRange.location -2, 2) withString:@"\n"]];
//            
//            NSLog(@"double return detected!");
//        }
//
//        
//        
//        if(textView.selectedRange.location +1 < textView.text.length){
//            lastTwoChars = [textView.text substringWithRange:NSMakeRange(textView.selectedRange.location -1, 2)];
//            
//            if ([lastTwoChars isEqualToString:@"\n\n"]){
//                
//                [textView setText:         [textView.text stringByReplacingCharactersInRange:NSMakeRange(textView.selectedRange.location -1, 2) withString:@"\n"]];
//                
//                NSLog(@"double return detected!");
//            }
//            
//            
//            
//            //if cursor is last or before last position
//        }else if (textView.selectedRange.location +1 >= textView.text.length) {
//        
//        }
//        
//        NSLog(@"lastTwoChars are: %@",lastTwoChars);
//
//    }
    
    
    
        //    NSLog(@"%@",[self.overviewTableView visibleCells]
    
//    self.lastCursorLocation = textView.selectedRange.location;
//    self.lastCursorLength = textView.selectedRange.length;

    
    NSIndexPath *ipForFirstCell = [NSIndexPath indexPathForRow:0 inSection:0];
//   CGFloat newRowHeight = [self tableView:overviewTableView heightForRowAtIndexPath: ipForFirstCell];

//    NSLog(@"before %@",    [textView description]);
//    [self.overviewTableView beginUpdates];
    [self.overviewTableView reloadData];
    [[[[overviewTableView cellForRowAtIndexPath:ipForFirstCell] contentView] viewWithTag:TEXT_TAG] becomeFirstResponder];

//    [self.overviewTableView setRowHeight:newRowHeight];
//        [[[self.overviewTableView cellForRowAtIndexPath:ipForFirstCell] contentView] setFrame:CGRectMake(0, 0, CELL_WIDTH, newRowHeight)];
//    [self.overviewTableView endUpdates];

//    NSLog(@"after: %@",    [textView description]);
    //    
//    [textView removeFromSuperview];
//    [[[self overviewTableView]cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] addSubview:textView];
//    [UIView setAnimationsEnabled:NO];
    
//    [[[textView superview]superview] setNeedsDisplay];
//        [[[textView superview] superview] layoutSubviews];
//    [textView setNeedsDisplay];
//    [overviewTableView reloadData];
    
    



//    NSLog(@"you SUCK!");
//    NSLog(@"%f",newRowHeight);
//    [[[overviewTableView cellForRowAtIndexPath:ipForFirstCell] contentView]setFrame:CGRectMake(0, 0, CELL_WIDTH, newRowHeight)];
//    [[overviewTableView cellForRowAtIndexPath:ipForFirstCell] setFrame:CGRectMake(0, 0, CELL_WIDTH, newRowHeight)];

//    [overviewTableView reloadSections:0 withRowAnimation:UITableViewRowAnimationNone];
    
}

// called whenever any text is to be inputted. checks if it is a return key and disallows it
// if there already is a return before or after cursor (to disallow double returns)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // if insertion point (not highlighted text)
    if (range.length ==0) {
        NSInteger cursorIndex = range.location;
        
        // if user types return
        if ([text isEqualToString:@"\n"]){

            //check if there is a return before cursor (short circuit AND to make sure cursor
            // isn't in FIRST position; cursorIndex-1 would then give negative number -> error)
            // if there is a return before cursor, don't change the text (i.e. don't let the 
            // \n go through)
            if( range.location > 0 && [textView.text characterAtIndex:cursorIndex-1] == '\n')
            {
                return  NO;
                
            //check if there is a return after cursor (short circuit AND to make sure cursor isn't
            // in LAST position; cursorIndex would be out of bounds if we try to get char)
            // if there is a return after cursor, don't let it through (return NO)
            } else if(cursorIndex < textView.text.length && [textView.text characterAtIndex:cursorIndex] == '\n') {
                return NO;
            }

        }
        
    }
    
    
    // BUG, user can enter more than one return if they use highlighting in some way (range.length>0)
    // or when copying and pasting a double return... negligible
    
    // in normal cases, allow the textView to be changed...
    return YES;
}


#pragma mark - UIScrollView delegate methods

// detects when view is dragged and dismisses keyboard (also notifies pageControlIsFlipping that the scroll is initiated by scrollView)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboardButton:nil];

}

// when pageControl is done scrolling page, set it back to false
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}

//code in this method from Apple example called pageControl
// detects when scrollView has scrolled and checks if page has flipped (to update the pageControl)
- (void)scrollViewDidScroll:(UIScrollView *)scrollview
{    

}




#pragma mark - Button and misc. event methods

// brings up option menu
// TODO tweak string names and options
- (IBAction)optionsButton:(id)sender {
    
    // create action sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Email", @"Punch Hazem", nil];
    // show action sheet
    [actionSheet showInView:self.view];
    
}// end optionsButton


// FOR TESTING ONLY (overwrites overview and today files to empty [actually, it keeps one line in there or sthg])
// TODO many bugs are creeping in from this method especially when performUpdate is called after it
- (IBAction)deleteSavedData:(id)sender {
    
    // empty array
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    
    // write over overview files with empty array
    [dataToSave writeToFile:[self saveFilePath: @"overview"] atomically:YES];

    //sets todayTextView to default
    [[self todayTextView] setText:@"Nichts"];
    
    // delete everything in overviewArray (reinitialize it)
    overviewArray = [[NSMutableArray alloc] init];

}// end deleteSavedData

/*
// code in this method from Apple example called PageControl
// when pageControl is clicked, flip page
- (IBAction)pageControlClicked:(id)sender {
    
    int page = pageControl.currentPage;
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
    
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: 
    pageControlIsFlipping = YES;
}
*/
 
// actually dismisses keyboard (called within many other methods like below one)
- (IBAction)dismissKeyboardButton:(id)sender {
//    NSLog(@"dismiss keyboard!");
    
    [(UITextView *)[[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TEXT_TAG] resignFirstResponder];
    textBeingEdited = NO;


}

/*
// when actionSheet buttons are pressed
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //TODO do stuff here...
    switch (buttonIndex) {
            
            // if email button
        case 0:
            
            break;
            
            // if punch button
        case 1:
            
            break;
            
            //case 2 is cancel (already handled; do nothing)
        default:
            break;
    }
    
}// end actionSheet:clickedButtonAtIndex:
*/
 
#pragma mark - Helper Methods

// adds a new entry in overviewArray with today's date
- (void)addNewEntryForToday
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //TODO make a new entry in overviewArray (check new carriage line is correct)
    // TODO expect bugs if carriage line doesnt work (trying to read date in first line)
    NSString *currentDayAsString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *newEntry = [[NSString alloc] initWithFormat:@"%@\r",currentDayAsString];
//    NSLog(@"LOOK HERE: %@",newEntry);
//    NSInteger indexToInsert = [overviewArray count]-1;
    NSInteger indexToInsert = 0;
//    if (indexToInsert<0) {
//        indexToInsert = 0;
//    }
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

// gets UITableViewCell contentView
- (UITableViewCell *) getCellContentViewWithCellIdentifier: (NSString *) cellIdentifier AtIndexPath: (NSIndexPath *) indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell" ];
    
    // set the whole cell to opaque (for performance issues when scrolling)
    [cell setOpaque:YES];
    
    //TODO consider setting each UILabel below as opaque also...
    
    // disable selection of table cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
     
    

    // get the rowHeight dynamically
    // TODO fix this here... can't get rowHeight dynamically AND reuseIdentifiers at same time
    // or can I?
    CGFloat rowHeight = [self tableView:[self overviewTableView] heightForRowAtIndexPath:indexPath];
    CGRect rect;
//    CGFloat rowHeight = 50.0;
    
//    NSLog(@"we're inside getCellContentView. this cell is not being reused (made from scratch) the rowHeight is %f", rowHeight);
    

    // TODO label tweaking below
    
    // the DAYNAME label is created and configured    
    // Create a dayname label for the cell and add to cell's contentView as a subview
    UILabel *daynameLabel;

    
	rect = CGRectMake(DAYNAME_OFFSET, 40, DAYNAME_WIDTH, LABEL_HEIGHT);
	daynameLabel = [[UILabel alloc] initWithFrame:rect];
	daynameLabel.tag = DAYNAME_TAG;
	daynameLabel.font = [UIFont boldSystemFontOfSize:DAYNAME_FONT_SIZE];
    daynameLabel.backgroundColor = [UIColor clearColor];
    
	// add the dayname label as a subview to the cell
    [cell.contentView addSubview:daynameLabel];
    
    
    // now, the DATE label is created and configured
    
    UILabel *dateLabel;
    
	rect = CGRectMake(DATE_OFFSET, 10, DATE_WIDTH, LABEL_HEIGHT);
	dateLabel = [[UILabel alloc] initWithFrame:rect];
	dateLabel.tag = DATE_TAG;
	dateLabel.font = [UIFont boldSystemFontOfSize:DATE_FONT_SIZE];
    dateLabel.backgroundColor = [UIColor clearColor];

    // add the date label as a subview to the cell
    [cell.contentView addSubview:dateLabel];
    
    
    
        
    
//    //create the "done" button
//    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
//    [doneButton setFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
////    [doneButton setImage:<#(UIImage *)#> forState:<#(UIControlState)#>]
//    [doneButton setBackgroundColor:[UIColor colorWithRed:0.1 green:0.0 blue:0.0 alpha:1.0]];
//    
//    
//    
//    doneButton.tag = BUTTON_TAG;
//    
//
//    
//    [doneButton setBackgroundColor: [[UIColor alloc]initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
//    
//    [cell.contentView addSubview:doneButton];
//    [cell.contentView bringSubviewToFront:doneButton];
//    
    // the TEXT label is created and configured
    
    UITextView *textView;

	rect = CGRectMake(TEXT_OFFSET, 0, TEXT_WIDTH, rowHeight);
	textView = [[UITextView alloc] initWithFrame:rect];
    //    textLabel.textAlignment = UITextAlignmentCenter;
	textView.tag = TEXT_TAG;
	textView.font = [UIFont boldSystemFontOfSize:TEXT_FONT_SIZE];
    textView.backgroundColor = [UIColor clearColor];
    textView.delegate = self;
    [textView setUserInteractionEnabled:YES];
//    textView.scrollEnabled = NO;
    // makes sure it's multiline
    //    [textView ] = UILineBreakModeWordWrap;
    //    textLabel.numberOfLines = 0;
    
    
    // add the text label as a subview to the cell
    [cell.contentView addSubview:textView];
    
    
    
//    // invisible dismissButton for each cell is made
//    UIButton *dismissButton;
//    
//    rect = CGRectMake(0, 0, CELL_WIDTH, rowHeight);
//    
//    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [dismissButton setFrame:rect];
//    [dismissButton setBackgroundColor:[UIColor clearColor]];
//    [dismissButton setExclusiveTouch:NO];
//    [dismissButton setEnabled:NO]
//    
//    [dismissButton addTarget:self action:@selector(dismissKeyboardButton:) forControlEvents:UIControlEventTouchUpInside];
//
//    [cell setAccessoryView:dismissButton];
//    
//    [cell bringSubviewToFront:cell.contentView];
//    [cell sendSubviewToBack:[cell accessoryView]];
    
//    [cell.contentView bringSubviewToFront:textView];
//    [cell.contentView sendSubviewToBack:[cell accessoryView]];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboardButton:)];
    [tap setNumberOfTapsRequired:1];
    
    [cell.contentView addGestureRecognizer:tap];
    
    // now that the cell has the 3 subviews (UILabels), return it
    return cell;

}// end getCellContentViewWithCellIdentifier:AtIndexPath:

// returns the string representation of overviewArray
- (NSString *) stringFromOverviewArray
{
    // goes through each entry and concatenates them all into one string
    NSString *overviewText=@"";
    for (NSString *entry in overviewArray) {
        overviewText = [NSString stringWithFormat:@"%@%@",overviewText,entry];
    }
    //returns that string
    return overviewText;
    
} //end stringFromOverviewArray

#pragma mark - Saving & loading methods


// TODO modify this to fit single-view concept
// performs all data updating necessary when loading (reads from files and writes to files)
- (void) performUpdateOnLoad
{
    //TODO worry about calling this BOTH when quitting (home button) AND when resuming (if u resume on a diff day, does it bug when 
    // saving?)
    
    /*
    // check if no edits were made
    if ([todayTextView.text length] <1 || [todayTextView.text isEqualToString:@"Nichts"]) {
        return;
    }
    */
    
    //TODO (new line of code here) populate the overviewArray from file data
    
    // if readData returns sthg (if file is there)
    if ([self readData] != nil) {
            [self setOverviewArray:[self readData]];
    
    //else if file is missing
    }else {
        [self addNewEntryForToday];
        [self saveData];
//        [overviewTableView reloadData];
        [overviewTableView reloadData];
        return;
    }

    
    
    //first, dismiss keyboard properly
    
    [[self dismissKeyBoardButton] setEnabled:NO];
    // dismiss keyboard in case it was up
    [self dismissKeyboardButton:nil];
    
    
    //create dateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //read in date from last entry
    
    NSString *lastEntryString = [[self overviewArray] objectAtIndex:0];
    // the range needed for the date (first line)
    NSRange rangeOfDate = [lastEntryString lineRangeForRange:NSMakeRange(0,1) ];
    NSString *lastEntryDateAsString = [lastEntryString substringWithRange: rangeOfDate];
    
    // REMOVE RETURN CARRIAGE FROM DATE!!!
    lastEntryDateAsString = [lastEntryDateAsString substringToIndex:lastEntryDateAsString.length -1];
    
    NSDate *lastEntryDate = [dateFormatter dateFromString:lastEntryDateAsString];
    
    // set up calendars and components (to compare currentDay and lastEntryDay)
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *currentDay = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate: lastEntryDate];
    NSDate *lastEntryDay = [cal dateFromComponents:components];
    

    
    //if last entry was not done today, make a new entry for today
    if(![currentDay isEqualToDate: lastEntryDay])
    {   
        //TODO debugging
        NSLog(@"it's not the same day!");
        
        
        
        [self addNewEntryForToday];
        
        
        // save to file
        [self saveData];
        
        // else if it's still today, do nothing
    } else
    {
        //TODO debugging
        NSLog(@"it's still the same day");
    }
    
    //TODO debugging and checking overview array 
    // read in file
//    NSLog(@"overviewArray count = %i", [[self overviewArray] count]);
//    for (int i=0; i<[overviewArray count]; i++) {
//        NSLog(@"index%i: %@",i,[overviewArray objectAtIndex:i]);
//    }

    // finally, reload the tableView (reloads cells and their subviews usw.)
//    [overviewTableView reloadData];
    
    [self.overviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];


    
    [overviewTableView reloadData];

    
    
    
    //TODO cursor details stored when first loaded
//    lastCursorLength = [(UITextView *)[[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag: TEXT_TAG] selectedRange].length;
//    lastCursorLocation = [(UITextView *)[[overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag: TEXT_TAG] selectedRange].location;
    lastCursorLength = 0;
    lastCursorLocation = 0;
    
    textBeingEdited = NO;
    
}// end performUpdateOnLoad

// helper method to get filePath
- (NSString *) saveFilePath: (NSString *) fileName
{
    // get file path (directory)
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // file name with extension
    NSString *fileWithExtension = [[NSString alloc] initWithFormat:@"%@.plist", fileName];
    // return full path with full name
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent: fileWithExtension];
} // end saveFilePath

// saves data from text field into file with given name
- (void) saveData
{
    // new array
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    
        //TODO (new line of code here) save the overviewArray to overviewFile
        dataToSave = [self overviewArray];
        
        // else, there is a problem, don't proceed.
    
    //writes text data to file
    [dataToSave writeToFile:[self saveFilePath: @"overview"] atomically:YES];
    
}// end saveData

// returns NSMutableArray of file contents
// TODO check for nil returns when calling this method
- (NSMutableArray *) readData
{
    
    //if file doesn't exist, return
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self saveFilePath: @"overview"]]) {
        NSLog(@"file not found. Cannot load.");
        return nil;
    }
    
    // new array
    NSMutableArray *dataToLoad;
    // read in file
    dataToLoad = [[NSMutableArray alloc] initWithContentsOfFile: [self saveFilePath:@"overview"] ];
    
    // check if file is not empty
    if([dataToLoad count] < 1)
    {
        NSLog(@"empty file. Cannot load.");
        // return empty array (to avoid exceptions with returning nil)
        return nil;
    }
    
    return dataToLoad;
}// end readDataFromFileName

#pragma mark - View methods & misc.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    overviewArray = [[NSMutableArray alloc]init];

    
    // UNCOMMENT to DELETE ALL DATA
//    [self saveData];
    
    
    //NOTE: all views and subviews are created in the nib. None are created within the code. Only the tableViewCells are created in code.
    
    // size of scrollView is set
    [scrollView setContentSize:CGSizeMake(640, 460)];

    // table view properties set here
    [overviewTableView setBounces:YES];
    [overviewTableView setAlwaysBounceVertical:YES];
    [overviewTableView setDelaysContentTouches:YES];
    [overviewTableView setScrollEnabled:YES];
    
    //TODO try out if selecting can work with textView editing
    overviewTableView.allowsSelection=NO;
    
    
    // performs all needed saving and loading action upon launch and close
    [self performUpdateOnLoad];
    
    NSLog(@"in ViewDidLoad");
} // end viewDidLoad


- (void)viewWillAppear:(BOOL)animated
{
    [self.overviewTableView beginUpdates];
    [self.overviewTableView endUpdates];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTodayTextView:nil];
    [self setOverviewTextView:nil];
    [self setDismissKeyBoardButton:nil];
    [self setOverviewTableView:nil];
    [self setOverviewTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
