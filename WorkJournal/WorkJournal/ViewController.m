//
//  ViewController.m
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@end

@implementation ViewController
@synthesize scrollView;
@synthesize todayTextView;
@synthesize overviewTextView;
@synthesize dismissKeyBoardButton;
@synthesize overviewArray;
@synthesize overviewTableView;




#define NAME_TAG 1
#define TIME_TAG 2
#define IMAGE_TAG 3

#define LEFT_COLUMN_OFFSET 10.0
#define LEFT_COLUMN_WIDTH 160.0

#define MIDDLE_COLUMN_OFFSET 170.0
#define MIDDLE_COLUMN_WIDTH 90.0

#define RIGHT_COLUMN_OFFSET 280.0

#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0


#pragma mark - UITableView protocol methods

//UITableViewDataSource protocol method
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(10, 50 * [indexPath row], 100, 50)];
//    [[cell detailTextLabel] setText:@"test"];
//    [[cell textLabel] setText:(NSString *) [overviewArray objectAtIndex:[indexPath row]]];
    
    UILabel *leftLabel;
	CGRect rect;
    
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    // Create a left label for the cell (has dayname and date)
	rect = CGRectMake(LEFT_COLUMN_OFFSET, (rowHeight - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
	leftLabel = [[UILabel alloc] initWithFrame:rect];
	leftLabel.tag = NAME_TAG;
	leftLabel.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
    
    // the cell's entry string
    NSString *entryString = [overviewArray objectAtIndex:[indexPath row]];
    
    // the range needed for the date (first line)
    NSRange rangeOfDate = [entryString lineRangeForRange:NSMakeRange(0,1) ];
    
    // extracted date
    NSString *date = [entryString substringWithRange: rangeOfDate];

    //TODO set the text to the first three letters of the DAYNAME
    leftLabel.text =  date;
	
    [cell.contentView addSubview:leftLabel];
//	leftLabel.highlightedTextColor = [UIColor whiteColor];
    
    NSLog(@"making cell number: %i", [indexPath row]);
    
    return cell;
}

//UITableViewDataSource protocol method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"section: %i", section);
    NSLog(@"overviewArray count: %i", [overviewArray count]);
    
    
    
    return [overviewArray count];
}

//UITableViewDelegate protocol method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

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
    
}


// FOR TESTING ONLY (overwrites overview and today files to empty [actually, it keeps one line in there])
- (IBAction)deleteSavedData:(id)sender {
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];

    [dataToSave addObject:@"eins"];
    [dataToSave writeToFile:[self saveFilePath: @"overview"] atomically:YES];

    [[self todayTextView] setText:@"Default text..."];


//    [dataToSave writeToFile:[self saveFilePath: @"today"] atomically:YES];
}

// dismisses keyboard
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
    
}


// called when user done editing
- (void)textViewDidEndEditing:(UITextView *)textView
{
    // save today text into today file
    [self saveDataInFileName:@"today"];
    
    // disable the button (to allow swiping scrolling)
    [[self dismissKeyBoardButton] setEnabled:NO];
    
    


}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[self dismissKeyBoardButton] setEnabled:YES];
}


#pragma mark - Helper Methods

// returns the string representation of overviewArray
- (NSString *) stringFromOverviewArray
{
    NSString *overviewText=@"";
    for (NSString *entry in overviewArray) {
        overviewText = [NSString stringWithFormat:@"%@%@",overviewText,entry];
    }
    
    return overviewText;
}

// performs all data updating necessary (reads from files and writes to files)
- (void) performUpdate
{
    //TODO worry about calling this BOTH when quitting (home button) AND when resuming (if u resume on a diff day, does it bug when 
    // saving?)
    
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
        
        //TODO fix adding a return line
        // appending new text to old text
//        NSString *oldOverviewText = [self readDataFromFileName:@"overview"];
        
        //TODO (new line of code here) read in overviewArray and concatenate to one string
        NSString *oldOverviewText= [self stringFromOverviewArray];
        
        // this is today's text added to overview
        NSString *textToAdd = [[NSString alloc]initWithFormat:@"%@\n%@",todayFileDateAsString, todayFileString] ;

        //TODO (new line of code) add new todayText to overviewArray
        [overviewArray addObject:textToAdd];
        
        // resulting overview text
        NSString *newOverviewText = [[NSString alloc]initWithFormat:@"%@\n%@",oldOverviewText, textToAdd] ;
        
        // setting overviewText to new value and saving it in file
        [[self overviewTextView] setText:newOverviewText];
        [self saveDataInFileName: @"overview"];
        
        // empties the todayFile and then sets todayTextView to sthg default
        [todayTextView setText:@""];
        [self saveDataInFileName:@"today"];
        [todayTextView setText:@"enter your work done today..."];
        
        
        
        // else if it's still today, update today and overview from files
    } else
    {
        //TODO debugging
        NSLog(@"it's still the same day");
        
        [todayTextView setText:[[self readDataFromFileName:@"today"] objectAtIndex:1] ];
//        [overviewTextView setText:[self readDataFromFileName:@"overview"]];
        //TODO (new line of code here) set overviewText to OverviewArray
        [overviewTextView setText:[self stringFromOverviewArray]];
        
    }
    
    //TODO debugging and checking overview file 
    // read in file
    
    NSLog(@"overviewArray count = %i", [[self overviewArray] count]);
    for (int i=0; i<[overviewArray count]; i++) {
        NSLog(@"index%i: %@",i,[overviewArray objectAtIndex:i]);
    }

    // TODO fix this here, being called but not reloading...
    NSLog(@"woopDeDoo!!");
    [overviewTableView reloadData];
    [overviewTableView setContentSize:CGSizeMake(320,1000)];
    [overviewTableView setDelaysContentTouches:NO];
    
    
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
}

// saves data from text field into file with name
- (void) saveDataInFileName:(NSString *) name
{
    // new array
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    
    
    // if today
    if ([name isEqualToString:@"today"]) {
        
        //TODO add meta data (date) in first line (using dateFormatter)
        //create dateFormatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // set date format
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        // add formatted date as first index
        [dataToSave addObject: [dateFormatter stringFromDate:[NSDate date]] ];
        
//        NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]] );
        
        // adds the today text into the new array
        [dataToSave addObject: [[NSString alloc]initWithFormat:@"%@",todayTextView.text]];
        
        // if overview
    } else if([name isEqualToString:@"overview"]) {
        
        // adds the overview text into the new array
        //[dataToSave addObject: overviewTextView.text];
        
        //TODO (new line of code here) save the overviewArray to overviewFile
        dataToSave = [self overviewArray];
        
        // else, there is a problem, don't proceed.
    } else {
        NSLog(@"invalid file name. Cannot save.");
        return;
    }
    
    //writes text data to file
    [dataToSave writeToFile:[self saveFilePath: name] atomically:YES];
    
    
}

// returns NSMutableArray of file contents
// TODO check for nil returns when calling this method
- (NSMutableArray *) readDataFromFileName: (NSString *) name
{
    
    //TODO need to check for invalid file path to avoid exceptions
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
        return nil;
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
