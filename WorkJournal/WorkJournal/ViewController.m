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
@synthesize scrollView, todayTextView, overviewTextView, overviewArray, overviewTableView, dismissKeyBoardButton;


#pragma mark - constants for label frames and sizes usw.

#define CELL_WIDTH 320.0
#define MAX_CELL_HEIGHT 2000.0
#define MIN_CELL_HEIGHT 44.0

#define DAYNAME_TAG 1
#define DATE_TAG 2
#define TEXT_TAG 3

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

    //TODO dequeing is currently turned OFF! uncomment two lines below to turn it ON!
    //    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //    if(cell == nil)
        cell = [self getCellContentViewWithCellIdentifier:@"cell" AtIndexPath:indexPath];
    
    
    // all label views are retrieved so their text can be changed
    UILabel *daynameLabel = (UILabel *)[cell viewWithTag:DAYNAME_TAG];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:DATE_TAG];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:TEXT_TAG];
    
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
    //sets the dateLabel text
    dateLabel.text = dateWithoutYearAsString;
    
    
    // finally, change textLabel text
    textLabel.text = textString;
    
    // TODO for debugging (tells when each cell is recreated or re-initialized)
    NSLog(@"making cell number: %i", [indexPath row]);
    
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
}

// informs (all) tableviews that they should have one section only...
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Button and Event Methods

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

// actually dismisses keyboard (called within many other methods like below one)
- (IBAction)dismissKeyboardButton:(id)sender {
    [todayTextView resignFirstResponder];
}

// detects when view is dragged and dismisses keyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboardButton:nil];
}

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


// when user done editing
// saves the todaytext and disables the dismissKeyboardButton
- (void)textViewDidEndEditing:(UITextView *)textView
{
    // save today text into today file
    [self saveDataInFileName:@"today"];
    
    // disable the button (to allow swiping scrolling)
    [[self dismissKeyBoardButton] setEnabled:NO];
}

//enables the dismissKeyboardButton only while editing
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[self dismissKeyBoardButton] setEnabled:YES];
}


#pragma mark - Helper Methods

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
    NSLog(@"we're inside getCellContentView. this cell is not being reused (made from scratch) the rowHeight is %f", rowHeight);
    
    // TODO label tweaking below
    
    // the DAYNAME label is created and configured    
    // Create a dayname label for the cell and add to cell's contentView as a subview
    UILabel *daynameLabel;
	CGRect rect;
    
	rect = CGRectMake(DAYNAME_OFFSET, (rowHeight - LABEL_HEIGHT) / 2.0, DAYNAME_WIDTH, LABEL_HEIGHT);
	daynameLabel = [[UILabel alloc] initWithFrame:rect];
	daynameLabel.tag = DAYNAME_TAG;
	daynameLabel.font = [UIFont boldSystemFontOfSize:DAYNAME_FONT_SIZE];
    daynameLabel.backgroundColor = [UIColor clearColor];
    
	// add the dayname label as a subview to the cell
    [cell.contentView addSubview:daynameLabel];
    
    
    // now, the DATE label is created and configured
    
    UILabel *dateLabel;
    
	rect = CGRectMake(DATE_OFFSET, (rowHeight - LABEL_HEIGHT) / 2.0 + 15, DATE_WIDTH, LABEL_HEIGHT);
	dateLabel = [[UILabel alloc] initWithFrame:rect];
	dateLabel.tag = DATE_TAG;
	dateLabel.font = [UIFont boldSystemFontOfSize:DATE_FONT_SIZE];
    dateLabel.backgroundColor = [UIColor clearColor];

    // add the date label as a subview to the cell
    [cell.contentView addSubview:dateLabel];
    
    
    
    // finally, the TEXT label is created and configured
    
    UILabel *textLabel;
    
	rect = CGRectMake(TEXT_OFFSET, 0, TEXT_WIDTH, rowHeight);
	textLabel = [[UILabel alloc] initWithFrame:rect];
//    textLabel.textAlignment = UITextAlignmentCenter;
	textLabel.tag = TEXT_TAG;
	textLabel.font = [UIFont boldSystemFontOfSize:TEXT_FONT_SIZE];
    textLabel.backgroundColor = [UIColor clearColor];
    
    // makes sure it's multiline
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    textLabel.numberOfLines = 0;

    
    // add the text label as a subview to the cell
    [cell.contentView addSubview:textLabel];
        
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

// performs all data updating necessary (reads from files and writes to files)
- (void) performUpdate
{
    //TODO worry about calling this BOTH when quitting (home button) AND when resuming (if u resume on a diff day, does it bug when 
    // saving?)
    
    // check if no edits were made
    if ([todayTextView.text length] <1 || [todayTextView.text isEqualToString:@"Nichts"]) {
        return;
    }
    
    //TODO (new line of code here) populate the overviewArray from file data
    [self setOverviewArray:[self readDataFromFileName:@"overview"]];
    
    
    //first, dismiss keyboard properly
    
    [[self dismissKeyBoardButton] setEnabled:NO];
    // dismiss keyboard in case it was up
    [self dismissKeyboardButton:nil];
    
    
    //create dateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    //read in the date from todayFile
    NSArray *todayArray = [self readDataFromFileName:@"today"];
    NSDate *todayFileDate = [dateFormatter dateFromString: [todayArray objectAtIndex:0]];    
    NSString *todayFileDateAsString= [todayArray objectAtIndex:0];
    
    // set up calendars and components (to compare currentDay and todayFileDay)
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *currentDay = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate: todayFileDate];
    NSDate *todayFileDay = [cal dateFromComponents:components];
    

    
    //if today is over, append today file into overview file (top of it)
    if(![currentDay isEqualToDate: todayFileDay])
    {
        //TODO debugging
        NSLog(@"it's not the same day!");
        
        // data from todayFile
        NSString *todayFileString = [[self readDataFromFileName:@"today"] objectAtIndex:1] ;
        
        // this is today's text added to overview
        NSString *textToAdd = [[NSString alloc]initWithFormat:@"%@\n%@",todayFileDateAsString, todayFileString] ;

        //TODO (new line of code) add new todayText to overviewArray
        [overviewArray addObject:textToAdd];
        
        // save into overview file
        [self saveDataInFileName: @"overview"];
        
        // empties the todayFile and then sets todayTextView to sthg default
        [todayTextView setText:@""];
        [self saveDataInFileName:@"today"];
        [todayTextView setText:@"Nichts"];
        
        // else if it's still today, update today from file (overview already read in by tableView)
    } else
    {
        //TODO debugging
        NSLog(@"it's still the same day");
        [todayTextView setText:[[self readDataFromFileName:@"today"] objectAtIndex:1] ];
    }
    
    //TODO debugging and checking overview file 
    // read in file
    NSLog(@"overviewArray count = %i", [[self overviewArray] count]);
    for (int i=0; i<[overviewArray count]; i++) {
        NSLog(@"index%i: %@",i,[overviewArray objectAtIndex:i]);
    }

    // finally, reload the tableView (reloads cells and their subviews usw.)
    [overviewTableView reloadData];
    
}// end performUpdate

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
- (void) saveDataInFileName:(NSString *) name
{
    // new array
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    
    // if today
    if ([name isEqualToString:@"today"]) {
        
        //create dateFormatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // set date format
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        
        // add formatted date as first index (first line)
        [dataToSave addObject: [dateFormatter stringFromDate:[NSDate date]] ];
        
        // adds the today text into the new array (as second line)
        [dataToSave addObject: [[NSString alloc]initWithFormat:@"%@",todayTextView.text]];
        
        // if overview
    } else if([name isEqualToString:@"overview"]) {
                
        //TODO (new line of code here) save the overviewArray to overviewFile
        dataToSave = [self overviewArray];
        
        // else, there is a problem, don't proceed.
    } else {
        NSLog(@"invalid file name. Cannot save.");
        return;
    }
    
    //writes text data to file
    [dataToSave writeToFile:[self saveFilePath: name] atomically:YES];
    
}// end saveDataInFileName:

// returns NSMutableArray of file contents
// TODO check for nil returns when calling this method
- (NSMutableArray *) readDataFromFileName: (NSString *) name
{
    
    //if file doesn't exist, return
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self saveFilePath: name]]) {
        NSLog(@"file not found. Cannot load.");
        return nil;
    }
    
    // new array
    NSMutableArray *dataToLoad;
    // read in file
    dataToLoad = [[NSMutableArray alloc] initWithContentsOfFile: [self saveFilePath:name] ];
    
    // check if file is not empty
    if([dataToLoad count] < 1)
    {
        NSLog(@"empty file. Cannot load.");
        // return empty array (to avoid exceptions with returning nil)
        return [[NSMutableArray alloc]init];
    }
    
    return dataToLoad;
}// end readDataFromFileName

#pragma mark - View methods & misc.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NOTE: all views and subviews are created in the nib. None are created within the code.
    
    // size of scrollView is set
    [scrollView setContentSize:CGSizeMake(640, 460)];

    // table view properties set here
    [overviewTableView setBounces:YES];
    [overviewTableView setAlwaysBounceVertical:YES];
    [overviewTableView setDelaysContentTouches:YES];
    [overviewTableView setScrollEnabled:YES];
    
    // performs all needed saving and loading action upon launch and close
    [self performUpdate];
    
    NSLog(@"in ViewDidLoad");
} // end viewDidLoad


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
