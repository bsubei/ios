//
//  ViewController.m
//  C
//
//  Created by Basheer Subei on 12/30/12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import "ViewController.h"





@interface ViewController ()

@end

@implementation ViewController

@synthesize tasksTableView;
NSMutableArray *tasksArray;
bool allowDismissingKeyboard=YES;


UITapGestureRecognizer *dismissKeyboard;

#pragma mark - TextViewDelegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        [UIView animateWithDuration:0.5 animations:^{        [textView setBackgroundColor:[UIColor clearColor]];}];
        [textView resignFirstResponder];
        return NO;
    }
    
    int initialLength = textView.text.length;
    int finalLength = [textView.text stringByReplacingCharactersInRange:range withString:text].length;
    //if backspace (shorter textView), then allow and return color to normal
    if (finalLength < initialLength) {
        [UIView animateWithDuration:0.5 animations:^{        [textView setBackgroundColor:[UIColor clearColor]];}];
        return YES;
    }
    
    // if char limit almost reached, allow this char and show red
    if (textView.text.length >= TASK_NAME_CHAR_LIMIT -1) {
        [UIView animateWithDuration:0.5 animations:^{        [textView setBackgroundColor:[UIColor redColor]];}];
    }
    //if char limit reached, don't allow
    if (textView.text.length >= TASK_NAME_CHAR_LIMIT ) {
        
        return NO;
        //else, allow
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{

        [UITextView animateWithDuration:0.5 animations:^{    [self.tasksTableView setContentInset:UIEdgeInsetsMake(0, 0, VERTICAL_KEYBOARD_OFFSET, 0)];}];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    
    
    [UITextView animateWithDuration:0.5 animations:^{    [self.tasksTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];}];
    

    
    UITableViewCell *cell = (UITableViewCell *)textView.superview.superview;
    
    //trim entry from now
    NSString * newEntryString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //check if empty string
    if ([newEntryString isEqualToString:@""]) {
        
        // deletes the last task (the one just created here)
        [self deleteThisTask: (UIButton *)[[self.tasksTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tasksTableView numberOfRowsInSection:0]-1 inSection:0]].contentView viewWithTag: DELETE_TAG]
         ];

    //else trim the name and set it to cell and update and save
    }else {
        [textView setText:newEntryString];
        [self updateTaskEntryFromCell:cell];
        [self saveDataToFile];
        
        //disable further editing of this textview
        [textView setEditable:NO];
        [textView setUserInteractionEnabled:NO];
        
        [UIView animateWithDuration:0.5 animations:^{        [textView setBackgroundColor:[UIColor clearColor]];}];

    }
    
    
}

#pragma mark - TableViewDelegates and stuff


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //dismiss keyboard
    if (allowDismissingKeyboard)
        [scrollView endEditing:YES];
    [self hideDelete];

}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

// depends on how many tasks there are (length of tasks array)
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tasksArray.count;
}

// initializes each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int index = indexPath.row;
    NSString *taskString = [tasksArray objectAtIndex:index];
    
    //now parse in the task's info
    
    /*
     * Each task's info will be saved into the array as four lines as such:
     * 1- taskName (string)
     * 2- currentCombo (int)
     * 3- bestCombo (int)
     * 4- ticked (int; 0 for NO and 1 for YES)
     * 5- lastLaunchDate (as a date)
     *
     */
    
    
    NSArray *stringArray = [taskString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *taskName = [stringArray objectAtIndex:0];
    int currentCombo = [(NSString *)[stringArray objectAtIndex:1] intValue];
    int bestCombo = [(NSString *)[stringArray objectAtIndex:2] intValue];
    int ticked = [(NSString *)[stringArray objectAtIndex:3] intValue];
    
    //Unused variable issue
    //NSString *lastLaunchDateString = [stringArray objectAtIndex:4];
//
//    //parse in the date
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    // set date format
//    NSString *formatterString = [NSString stringWithFormat:@"dd-MM-yyyy"];
//    [dateFormatter setDateFormat:formatterString];
//    // gets the date from the formatter
//    NSDate *lastLaunchDate = [dateFormatter dateFromString:lastLaunchDateString];
    
    bool isTicked = ticked ==1 ? YES : NO; //if 1, then set isTicked to YES, otherwise NO.
    
    // the entry's cell is initialized (gets reusable cell if possible)
    UITableViewCell *cell;
	
    // reuse cell with dequeueing if possible
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // if not possible, make cell from scratch
    if(cell == nil)
        cell = [self getCellContentViewWithCellIdentifier:@"cell" AtIndexPath:indexPath];
    
    //now, let's set up the views for the cell using the info
    
    UILabel *currentComboLabel = (UILabel *)[cell viewWithTag:CURRENTCOMBO_TAG];
    UILabel *bestComboLabel = (UILabel *)[cell viewWithTag:BESTCOMBO_TAG];
    UITextView *taskNameTextView = (UITextView *)[cell viewWithTag:TEXT_TAG];
    UIButton *tickButton = (UIButton *)[cell viewWithTag:TICK_TAG];
    UIButton *deleteButton = (UIButton *)[cell viewWithTag:DELETE_TAG];
    
    
    [currentComboLabel setText:[NSString stringWithFormat:@"%i", currentCombo]];
    [bestComboLabel setText:[NSString stringWithFormat:@"%i", bestCombo]];
    [taskNameTextView setText: taskName];
    [tickButton setSelected:isTicked];
    [deleteButton setHidden:YES];
    
    
    return cell;
    
} // end tableView:cellForRowAtIndexPath:


// gets UITableViewCell contentView (basically creates each cell from scratch here)
- (UITableViewCell *) getCellContentViewWithCellIdentifier: (NSString *) cellIdentifier AtIndexPath: (NSIndexPath *) indexPath
{
    // creates cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell" ];
    
    // set the whole cell to opaque (for performance issues when scrolling)
    [cell setOpaque:NO];
    [cell.contentView setOpaque:NO];
	[cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    //TODO consider setting each UILabel below as opaque also...
    
    // disable selection of table cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
    CGRect rect;
	
    // TODO label tweaking below
    
    // the CURRENTCOMBO label is created and configured
    // Create a CURRENTCOMBO label for the cell and add to cell's contentView as a subview
    UILabel *currentComboLabel;
	
	rect = CGRectMake(CURRENTCOMBO_X_OFFSET - CURRENTCOMBO_WIDTH, CURRENTCOMBO_Y_OFFSET, CURRENTCOMBO_WIDTH, CURRENTCOMBO_HEIGHT);
	currentComboLabel = [[UILabel alloc] initWithFrame:rect];
	[currentComboLabel setTextAlignment:UITextAlignmentLeft];
//	[currentComboLabel setLineBreakMode:UILineBreakModeWordWrap];
	
	currentComboLabel.tag = CURRENTCOMBO_TAG;
	currentComboLabel.font = [UIFont boldSystemFontOfSize:CURRENTCOMBO_FONT_SIZE];
    //    currentComboLabel.backgroundColor = [UIColor whiteColor];
    currentComboLabel.backgroundColor = [UIColor clearColor];
    
	[currentComboLabel setOpaque:NO];
	
	// add the CURRENTCOMBO label as a subview to the cell
    [cell.contentView addSubview:currentComboLabel];
    //	[cell.contentView sendSubviewToBack:currentComboLabel];
    
    // the BESTCOMBO label is created and configured
    // Create a BESTCOMBO label for the cell and add to cell's contentView as a subview
    UILabel *bestComboLabel;
	
	rect = CGRectMake(BESTCOMBO_X_OFFSET - BESTCOMBO_WIDTH, BESTCOMBO_Y_OFFSET, BESTCOMBO_WIDTH, BESTCOMBO_HEIGHT);
	bestComboLabel = [[UILabel alloc] initWithFrame:rect];
	[bestComboLabel setTextAlignment:UITextAlignmentLeft];
//	[bestComboLabel setLineBreakMode:UILineBreakModeWordWrap];
	
	bestComboLabel.tag = BESTCOMBO_TAG;
	bestComboLabel.font = [UIFont boldSystemFontOfSize:BESTCOMBO_FONT_SIZE];
    //    bestComboLabel.backgroundColor = [UIColor whiteColor];
    bestComboLabel.backgroundColor = [UIColor clearColor];
    
	[bestComboLabel setOpaque:NO];
	
	// add the BESTCOMBO label as a subview to the cell
    [cell.contentView addSubview:bestComboLabel];
	
    
    
    // now the actual taskNameTextView (to hold user-entered text) is created and configured
    UITextView *taskNameTextView;
	
	// get the rowHeight dynamically //TODO check if we need this
    CGFloat rowHeight = [self tableView:self.tasksTableView heightForRowAtIndexPath:indexPath];
	
	rect = CGRectMake(TEXT_X_OFFSET, TEXT_Y_OFFSET, TEXT_WIDTH, rowHeight - TEXT_Y_OFFSET*2);
	taskNameTextView = [[UITextView alloc] initWithFrame:rect];
    //    textLabel.textAlignment = UITextAlignmentCenter;
	taskNameTextView.tag = TEXT_TAG;
	taskNameTextView.font = [UIFont boldSystemFontOfSize:TEXT_FONT_SIZE];
    //    taskNameTextView.backgroundColor = [UIColor whiteColor];
    taskNameTextView.backgroundColor = [UIColor clearColor];
    
    taskNameTextView.delegate = self;
    [taskNameTextView setUserInteractionEnabled:NO];
	[taskNameTextView setOpaque:NO];
	// REMOVES the inner margins inside the taskNameTextView (fixes dynamic height)
	[taskNameTextView setContentInset:UIEdgeInsetsMake(-8,-8,-8,-8)];
	
    taskNameTextView.scrollEnabled = NO;
	[taskNameTextView setReturnKeyType:UIReturnKeyDone];
    
    // add the text view as a subview to the cell
    [cell.contentView addSubview:taskNameTextView];
    [cell.contentView bringSubviewToFront:taskNameTextView];
    
    
    // create tickButton
    UIButton *tickButton;
//    tickButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    tickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tickButton setImage:[UIImage imageNamed:@"tickOff.png"] forState:UIControlStateNormal];
    [tickButton setImage:[UIImage imageNamed:@"tickOn.png"] forState:UIControlStateSelected];
    rect = CGRectMake(TICK_X_OFFSET, TICK_Y_OFFSET, TICK_WIDTH, TICK_HEIGHT);
    [tickButton setFrame:rect];

    tickButton.tag = TICK_TAG;
    [tickButton setEnabled:YES];
    [cell.contentView addSubview:tickButton];
    [cell.contentView bringSubviewToFront:tickButton];
    
    //TODO create this method and figure out how we will pass the button id to the method
    [tickButton addTarget:self action:@selector(tickToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    // create and set up the delete button (hidden usually)
    UIButton *deleteButton;
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    rect = CGRectMake(DELETE_X_OFFSET, DELETE_Y_OFFSET, DELETE_WIDTH, DELETE_HEIGHT);
    [deleteButton setFrame:rect];
    [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    deleteButton.tag = DELETE_TAG;
    [deleteButton setEnabled:YES];
    [deleteButton setHidden:YES];
    [cell.contentView addSubview:deleteButton];
    [cell.contentView bringSubviewToFront:deleteButton];
    
    // set up swipe rec for the cell (to reveal the delete button)
    UISwipeGestureRecognizer *revealDeleteButton = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealDelete:)];
    [revealDeleteButton setDirection:UISwipeGestureRecognizerDirectionRight];
    [revealDeleteButton setEnabled:YES];
    [cell addGestureRecognizer:revealDeleteButton];
    
    [deleteButton addTarget:self action:@selector(deleteThisTask:) forControlEvents:UIControlEventTouchUpInside];
    
    // now that the cell has all the subviews ready, return it
    return cell;
	
}// end getCellContentViewWithCellIdentifier:AtIndexPath:

#pragma mark - buttons and stuff

// checks if less than maximum_tasks and creates a new cell for the task
- (IBAction)createNewTask:(UIButton *)sender {
    
    // if before last one, gray out the '+' button
    if(tasksArray.count == MAXIMUM_TASKS-1){
        [self.addNewTaskButton setEnabled:NO];


    }

    
    // if less than maximum and not placeholder (to avoid multiple placeholder tasks)
    if(tasksArray.count < MAXIMUM_TASKS){

        NSString *nowDateAsString = [self nowDateAsString];
        
        // make a new entry and add it to array
        NSString *newEntryString= [NSString stringWithFormat:@"\n0\n0\n0\n%@", nowDateAsString];
        [tasksArray addObject:newEntryString];
        // refresh table and save to file
        [self.tasksTableView reloadData];
        [self saveDataToFile];

        
        // set up this stuff to dismiss kb on anywhere tap
        allowDismissingKeyboard=NO;
        [self.hugeInvisibleButton setHidden:NO];
        [self.hugeInvisibleButton setEnabled:YES];
        
        // after a delay of one second, re-enable scroll dismisses kb and remove button
        [self performSelector:@selector(toggleAllowDismissingKeyboard) withObject:nil afterDelay:1.0];


        // scroll to that cell
        [self.tasksTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tasksArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        //then make it first responder (after delay to guarantee that the cell is scrolled to and visible [i.e. it was initialized and not null])
        [self performSelector:@selector(makeTextViewFirstResponder) withObject:nil afterDelay:0.3];

        
    } 

    // remove placeholder since we now have tasks
    [self.placeholderLabel setHidden:YES];
}

- (void)deleteThisTask:(UIButton *)deleteButton
{
    //get index of task and use it to remove task from array
    int indexOfTask = [self.tasksTableView indexPathForCell:(UITableViewCell *)deleteButton.superview.superview].row;
    [tasksArray removeObjectAtIndex:indexOfTask];
    
    //reload tableview from array data and save data to file
    [self.tasksTableView reloadData];
    [self saveDataToFile];
    
    //if last task deleted, then show placeholder
    if (tasksArray.count==0) {
        [self.placeholderLabel setHidden:NO];
    }
    
    //re-enable the '+' button
    [self.addNewTaskButton setEnabled:YES];
}

// dismisses kb and removes the huge button
- (IBAction)hugeInvisibleButton:(id)sender {
    [self.tasksTableView endEditing:YES];
    [self.hugeInvisibleButton setHidden:YES];
    [self.hugeInvisibleButton setEnabled:NO];
}

// when picker time is changed for reminder
- (IBAction)timeSet:(id)sender {

    // if switched on, remove all old reminders and reschedule a new one
    if (self.reminderSwitch.isOn) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self setDailyReminder];
    }
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    NSDate *pickerDate = self.timePicker.date;

    NSString *pickerString = [formatter stringFromDate:pickerDate];
    //set the reminder time user pref to the picker value
    [[NSUserDefaults standardUserDefaults] setValue:pickerString forKey:@"reminderTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
} // end timeSet:



// runs when toggled reminder on and off
- (IBAction)toggleReminder:(id)sender {

//    remove all old reminders anyways
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //if toggled on, set a new reminder
    if ([self.reminderSwitch isOn])
        [self setDailyReminder];
    
    
    // set the reminder toggle user pref to this switch value
    NSString *switchString;
    if ([self.reminderSwitch isOn])
        switchString = @"1";
    else
        switchString = @"0";
    
    [[NSUserDefaults standardUserDefaults] setValue:switchString forKey:@"reminderToggle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}// end toggleReminder:

//toggles the tickButton (selects it on and off)
- (void)tickToggle:(UIButton *)sender
{

    UIButton *tick = sender;
    
    // TODO and change the combo values accordingly
    UILabel *currentComboLabel = (UILabel *)[(UITableViewCell *)tick.superview.superview viewWithTag:CURRENTCOMBO_TAG];
    UILabel *bestComboLabel = (UILabel *)[(UITableViewCell *)tick.superview.superview viewWithTag:BESTCOMBO_TAG];
    
    //if it is selected, unselect it (toggle it off)
    if ([tick isSelected]) {
        [tick setSelected:NO];
        
        //if current is best, then decrement best
        if (currentComboLabel.text.intValue == bestComboLabel.text.intValue) {
//            bestComboLabel.text = [NSString stringWithFormat:@"%i", (bestComboLabel.text.intValue -1)];
        }
        //now decrement current anyways
        currentComboLabel.text = [NSString stringWithFormat:@"%i", (currentComboLabel.text.intValue -1)];
        
        // if it is not, then select it (toggle it on)
    }else{
        
        [tick setSelected:YES];
        
        //if current is best, then increment best
        if (currentComboLabel.text.intValue == bestComboLabel.text.intValue) {
            bestComboLabel.text = [NSString stringWithFormat:@"%i", (bestComboLabel.text.intValue +1)];
        }
        //now increment current anyways
        currentComboLabel.text = [NSString stringWithFormat:@"%i", (currentComboLabel.text.intValue +1)];
        
    }
    
    
    //save to file
    [self updateTaskEntryFromCell:(UITableViewCell *)sender.superview.superview];
    [self saveDataToFile];
    
    //also hide delete button in case it was open
    [self hideDelete];
    
    //also dismiss kb in case it is up
    [self.tasksTableView endEditing:YES];
    
}// end tickToggle


#pragma mark - File I/O

// updates the array from current state (this is run after any user interaction)
- (void)updateTaskEntryFromCell:(UITableViewCell *)cell
{
    
    //gets the views from the cell
    UILabel *currentComboLabel = (UILabel *)[cell viewWithTag:CURRENTCOMBO_TAG];
    UILabel *bestComboLabel = (UILabel *)[cell viewWithTag:BESTCOMBO_TAG];
    UITextView *taskNameTextView = (UITextView *)[cell viewWithTag:TEXT_TAG];
    UIButton *tickButton = (UIButton *)[cell viewWithTag:TICK_TAG];
    
    // extracts info from these views
    NSString *taskNameString = taskNameTextView.text;
    int currentCombo = (int)currentComboLabel.text.intValue;
    int bestCombo = (int)bestComboLabel.text.intValue;
    int tick = tickButton.selected == YES ? 1 : 0; //if selected, tick=1, else tick=0;
    
    //constructs string and updates taskArray with it
//    NSString *taskString = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskNameString, currentCombo, bestCombo, tick, lastLaunchDateString];
    NSString *taskString = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskNameString, currentCombo, bestCombo, tick, [self nowDateAsString]];
  

    int index = [self.tasksTableView indexPathForCell:cell].row;
    [tasksArray replaceObjectAtIndex:index withObject:taskString];
    
}// end refreshTasksArray

// reads in tasks array from file
- (NSMutableArray *)loadTasksArrayFromFile
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
}

// saves data from text field into file with given name
- (void) saveDataToFile
{
    // new array
    NSMutableArray *dataToSave = tasksArray;
	
    //writes text data to file
    [dataToSave writeToFile:[self savefilePath] atomically:YES];
    
}// end saveData

// helper method to get filePath
- (NSString *) savefilePath
{
    // get file path (directory)
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // file name with extension
    NSString *fileWithExtension = [[NSString alloc] initWithFormat:@"tasks.plist"];
    // return full path with full name
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent: fileWithExtension];
} // end saveFilePath

- (void)handleReminderUserPrefs
{
    //START reminder user prefs
    //tries to get reminder user prefs and set ui correspondingly
    
    //if the time pref is set
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"reminderTime"]){
        
        //save it as string
        NSString *timeString = [[NSUserDefaults standardUserDefaults] valueForKey:@"reminderTime"];
        
        //convert to date using formatter
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSDate *time = [formatter dateFromString:timeString];
        
        //set timePicker to it
        [self.timePicker setDate:time];
        
        //else if time pref is not set
    } else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSDate *nowDate = [NSDate date];
        NSString *nowString = [formatter stringFromDate:nowDate];
        //set it at NOW
        
        [[NSUserDefaults standardUserDefaults] setValue:nowString forKey:@"reminderTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //now set the timePicker as it
        [self.timePicker setDate:nowDate];

    }
    
    
    // if reminderToggle pref is set
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"reminderToggle"]) {
        
        //get the value
        NSString *toggle = [[NSUserDefaults standardUserDefaults] valueForKey:@"reminderToggle"];
        //set the toggle switch accordingly
        if ([toggle isEqualToString:@"1"])
            [self.reminderSwitch setOn:YES];
        else
            [self.reminderSwitch setOn:NO];
        
    //else if it's not set
    } else{
        
        // then set the pref to NO
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"reminderToggle"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //set switch to NO
        [self.reminderSwitch setOn:NO];
    }
    //DONE reminder user prefs
}
#pragma mark - Helper Methods

// schedules a daily uilocalnotification
- (void)setDailyReminder
{
    
    UILocalNotification *dailyReminder = [[UILocalNotification alloc] init];
    
    //set the local notification
    
    [dailyReminder setFireDate: self.timePicker.date];
    [dailyReminder setRepeatCalendar:[NSCalendar currentCalendar]];
    [dailyReminder setTimeZone:[NSTimeZone defaultTimeZone]];
    [dailyReminder setSoundName:UILocalNotificationDefaultSoundName];
    
    //sets title and text (?) of alertView
    [dailyReminder setAlertAction:@"C"];
    [dailyReminder setAlertBody:@"Don't forget your daily tasks!"];
    
    [dailyReminder setRepeatInterval:NSDayCalendarUnit];
    
    //set the reminder
    [[UIApplication sharedApplication] scheduleLocalNotification:dailyReminder];
} // end setDailyReminder

- (NSString *)nowDateAsString
{
    //get now date and parse as string
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set date format
    NSString *formatterString = [NSString stringWithFormat:@"dd-MM-yyyy"];
    [dateFormatter setDateFormat:formatterString];
    // returns the date from the formatter
    return [dateFormatter stringFromDate:[NSDate date]];

}

//checks if d1 and d2 are consecutive (where d1 is before d2)
- (BOOL)date:(NSDate *) d1 AndDateAreConsecutive:(NSDate *) d2
{
    
    //add 1 day to d1 (60*60*24 secodns is one day)
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    d1 = [theCalendar dateByAddingComponents:dayComponent toDate:d1 options:0];
    
	
	//if d1 is same day as d2, then they are consecutive, return YES
	if([self isDate:d1 sameDayAsDate:d2]){ return YES;}
	
	// if not consecutive, return NO
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

// (after delay) grabs last textview (just created) and sets it as first responder
- (void)makeTextViewFirstResponder
{
    // getting last textview in table
    UITextView *textview =(UITextView *)[(UITableViewCell *)[tasksTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tasksArray.count-1 inSection:0]].contentView viewWithTag:TEXT_TAG] ;

    [textview setUserInteractionEnabled:YES];
    [textview setEditable:YES];
    [textview becomeFirstResponder];
}

- (void)revealDelete:(UISwipeGestureRecognizer *)sender
{
    // first hide all delete buttons
    [self hideDelete];
    
    // then show this delete button
    UIButton *deleteButton = (UIButton *)[((UITableViewCell *)sender.view).contentView viewWithTag:DELETE_TAG];
    [deleteButton setHidden:NO];
    
    [self.tasksTableView endEditing:YES];
}

- (void)hideDelete
{
    
    //set all delete buttons to hidden
    for (int i=0; i< [self.tasksTableView numberOfRowsInSection:0]; i++) {
        [[[self.tasksTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].contentView viewWithTag:DELETE_TAG] setHidden:YES];
    }
}

- (void)toggleAllowDismissingKeyboard
{
    // if it's already YES, set it to NO. If it's already NO, set it to YES;
    allowDismissingKeyboard = allowDismissingKeyboard ? NO : YES;
    

    [self.hugeInvisibleButton setHidden:YES];
}

#pragma mark - App Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
   //LOAD FROM FILES
    //set up tasks array from files if file found
    if ([self loadTasksArrayFromFile] != nil) {
        tasksArray = [self loadTasksArrayFromFile];
    }else{
//        tasksArray = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@\n0\n0\n0",TASK_NAME_PLACEHOLDER], nil];
        tasksArray = [[NSMutableArray alloc] init];
    }
    
    
    //CHECK TICKS
    //for each cell, perform tickChecks
    
    for (int i=0; i<tasksArray.count; i++) {
        
        // get task info
        
        NSString *taskString = [tasksArray objectAtIndex:i];
        
        NSArray *stringArray = [taskString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSString *taskName = [stringArray objectAtIndex:0];
        int currentCombo = [(NSString *)[stringArray objectAtIndex:1] intValue];
        int bestCombo = [(NSString *)[stringArray objectAtIndex:2] intValue];
        int ticked = [(NSString *)[stringArray objectAtIndex:3] intValue];
        NSString *lastLaunchDateString = [stringArray objectAtIndex:4];
        
        //parse in the lastLaunch date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // set date format
        NSString *formatterString = [NSString stringWithFormat:@"dd-MM-yyyy"];
        [dateFormatter setDateFormat:formatterString];
        // gets the date from the formatter
        NSDate *lastLaunchDate = [dateFormatter dateFromString:lastLaunchDateString];
        
        //perform tickChecks (to update any ticks etc.)
        
        // if not same day (if different days)
        if (![self isDate:[NSDate date] sameDayAsDate: lastLaunchDate ]) {


            // and if lastTicked
            if (ticked==1) {

                // and if consecutiveDays
                if ([self date:lastLaunchDate AndDateAreConsecutive:[NSDate date]]) {

                    //then SUCCESS
                    ticked=0;
                    
                    //sets tick
                    
                    NSString *modifiedEntry = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskName, currentCombo, bestCombo, ticked, lastLaunchDateString];
                    [tasksArray replaceObjectAtIndex:i withObject:modifiedEntry];
                    [self.tasksTableView reloadData];
                    
                     //else not consecutive, FAIL
                } else{

                    currentCombo=0;//reset currentCombo
                    ticked=0;
                    //sets tick
                    
                    NSString *modifiedEntry = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskName, currentCombo, bestCombo, ticked, lastLaunchDateString];
                    [tasksArray replaceObjectAtIndex:i withObject:modifiedEntry];
                    [self.tasksTableView reloadData];
                }


            //else if not lastTicked, then FAIL
            } else{
                currentCombo=0;
                ticked=0;
                //sets tick

                
                NSString *modifiedEntry = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskName, currentCombo, bestCombo, ticked, lastLaunchDateString];
                [tasksArray replaceObjectAtIndex:i withObject:modifiedEntry];
                [self.tasksTableView reloadData];
            }

        
        
        }//if same day, do nothing and go on

        
        
        //finally, set new lastLaunchDate (now)
        lastLaunchDateString=[dateFormatter stringFromDate:[NSDate date]];
        NSString *modifiedEntry = [NSString stringWithFormat:@"%@\n%i\n%i\n%i\n%@", taskName, currentCombo, bestCombo, ticked, lastLaunchDateString];
        [tasksArray replaceObjectAtIndex:i withObject:modifiedEntry];
    }//end for (that goes through each cell)
    
    
    
    // SET UP UI STUFF
    [self.hugeInvisibleButton setExclusiveTouch:YES];
    [self.hugeInvisibleButton setBackgroundColor:[UIColor clearColor]];
    [self.hugeInvisibleButton setEnabled:NO];
    
    // table view properties set here
    [self.tasksTableView setBounces:YES];
    [self.tasksTableView setAlwaysBounceVertical:YES];
    [self.tasksTableView setDelaysContentTouches:YES];
    [self.tasksTableView setScrollEnabled:YES];
	[self.tasksTableView setOpaque:NO];
    [self.tasksTableView setAllowsSelection:NO];
    [UITextView animateWithDuration:0.5 animations:^{    [self.tasksTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];}];
    
    // sets slidingView outside
    [self.slidingView setFrame:CGRectMake(0, 650, self.slidingView.frame.size.width, self.slidingView.frame.size.height)];
    
    [self.slidingView setHidden:NO];
    
    // handles everything related to setting user prefs for reminder ui
    [self handleReminderUserPrefs];
    
    //show placeholder if any tasks remaining
    if (tasksArray.count >0)
        [self.placeholderLabel setHidden:YES];
    else
        [self.placeholderLabel setHidden:NO];

    [self.addNewTaskButton setAdjustsImageWhenDisabled:YES];
    
    
    [self.addNewTaskButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.addNewTaskButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    if (tasksArray.count == MAXIMUM_TASKS) {
        [self.addNewTaskButton setEnabled:NO];
    }

    
    [self.tasksTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTasksTableView:nil];
    [self setPlaceholderLabel:nil];
    [self setHugeInvisibleButton:nil];
    [self setSlidingView:nil];
    [self setTimePicker:nil];
    [self setReminderSwitch:nil];
    [self setAddNewTaskButton:nil];
    [super viewDidUnload];
}

- (IBAction)slideViewIn:(id)sender {

    //takes care if delet button still there when sliding this in.
    [self hideDelete];
    
    // perform sliding animation
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION animations:^(void){
        
    

        [self.slidingView setFrame:(CGRectMake(0, 0, self.slidingView.frame.size.width, self.slidingView.frame.size.height)) ];
    }//end block (everything inside this block is animated)
     ];//end animateWithDuration:
    

}

- (IBAction)slideViewOut:(id)sender {
  
    // perform sliding animation
    [UIView animateWithDuration:SLIDE_ANIMATION_DURATION animations:^(void){
        
        
        [self.slidingView setFrame:(CGRectMake(0, 650, self.slidingView.frame.size.width, self.slidingView.frame.size.height)) ];
    }//end block (everything inside this block is animated)
     ];//end animateWithDuration:
    
    
}
@end
