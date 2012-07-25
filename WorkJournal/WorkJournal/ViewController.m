//
//  ViewController.m
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollView;
@synthesize todayTextView;
@synthesize overviewTextView;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


    //NOTE: all views and subviews are created in the nib. None are created within the code.
    
    // size of scrollView is set
    [scrollView setContentSize:CGSizeMake(640, 460)];
    
    //read in today text
    
    //create dateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    
    //TODO exception here (invalidArgumentException)
    //read in the date from todayFile
    NSArray *todayArray = [[NSArray alloc] initWithContentsOfFile: [self saveFilePath:@"today"]];
    NSDate *todayFileDate = [dateFormatter dateFromString: [todayArray objectAtIndex:0]];
    NSLog(@"today's date %@", todayFileDate);
    
    

    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *currentDay = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate: todayFileDate];
    NSDate *todayFileDay = [cal dateFromComponents:components];

    
    // TODO NOTE: if day is over while app is on, it will not be updated until app is relaunched
    
    //TODO checks if todayFileDay is NOT (real) today NOT WORKING CURRENTLY
    //if today is over, append today file into overview file (top of it)
    if(![currentDay isEqualToDate: todayFileDay])
    {
    
        
        NSString *todayFileString = [self readDataFromFileName:@"today"] ;
        
        
        NSLog(@"compared days from todayFile, they are diff days!");
        NSLog(@"today Day: %@  and current Day: %@",todayFileDay, currentDay);
        
        
        //TODO fix adding a return line
        //TODO append formatted date (currentDate) as first line then todayFileString
        NSString *oldOverviewText = [self readDataFromFileName:@"overview"];
        NSString *newOverviewText = [[NSString alloc]initWithFormat:@"%@%@",oldOverviewText, todayFileString] ;
        
        NSLog(@"new overview text: %@", newOverviewText);
        
        [[self overviewTextView] setText:newOverviewText];
        [self saveDataInFileName: @"overview"];
        
        // empties the todayFile and then sets todayTextView to sthg default
        [todayTextView setText:@""];
        [self saveDataInFileName:@"today"];
        [todayTextView setText:@"enter your work done today..."];
        
        
    // else, move today file string into today textView
    } else
    {
        NSLog(@"compared days from todayFile, they are SAME days!");
        [todayTextView setText:[self readDataFromFileName:@"today"] ];
        [overviewTextView setText:[self readDataFromFileName:@"overview"]];
    }
    
    
    
    // read in overview file and put into overview textView
    
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTodayTextView:nil];
    [self setOverviewTextView:nil];
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
//    NSLog(@"%@", todayTextView.text);
}

// detects when view is dragged and dismisses keyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboardButton:nil];
}

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
        
        NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]] );
        
        // adds the today text into the new array
        [dataToSave addObject: [[NSString alloc]initWithFormat:@"%@",todayTextView.text]];
        
    // if overview
    } else if([name isEqualToString:@"overview"]) {
        
        // adds the overview text into the new array
        [dataToSave addObject: overviewTextView.text];
        
    // else, there is a problem, don't proceed.
    } else {
        NSLog(@"invalid file name. Cannot save.");
        return;
    }
    
    //writes text data to file
    [dataToSave writeToFile:[self saveFilePath: name] atomically:YES];
    

    
    
    //TODO life cycle debugging
//    NSLog(@"end of saveData");
    
}

// returns NSString of file
// TODO check for nil returns when calling this method
- (NSString *) readDataFromFileName: (NSString *) name
{
    
    //TODO need to check for invalid file path to avoid exceptions
    //if file doesn't exist, return
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self saveFilePath: name]]) {
        return nil;
    }

    // new array
    NSMutableArray *dataToLoad;
    
    
    // read in file
    dataToLoad = [[NSMutableArray alloc] initWithContentsOfFile: [self saveFilePath:name] ];
    
    
    //TODO debugging
//    NSLog(@"%@", [dataToLoad objectAtIndex:0]);
//    NSLog(@"%@", [dataToLoad objectAtIndex:1]);
//    NSLog(@"%@", [[dataToLoad objectAtIndex:0] class]);
    
    // if today
    if ([name isEqualToString:@"today"]) {
        
        // return 2nd index (1st is meta data)
        return [dataToLoad objectAtIndex:1];
        // if overview
    } else if([name isEqualToString:@"overview"]) {

        // return overview text
        return [dataToLoad objectAtIndex:0];

        // else, there is a problem, don't proceed.
    } else {
        NSLog(@"invalid file name. Cannot load.");
        return nil;
    }
    
}


@end
