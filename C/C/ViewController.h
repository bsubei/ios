//
//  ViewController.h
//  C
//
//  Created by Basheer Subei on 12/30/12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAXIMUM_TASKS 5

#define VERTICAL_KEYBOARD_OFFSET 220

#define TABLE_CELL_HEIGHT 144.0

#define CURRENTCOMBO_TAG 0
#define BESTCOMBO_TAG 1
#define TEXT_TAG 2
#define TICK_TAG 3
#define DELETE_TAG 4


#define CURRENTCOMBO_X_OFFSET 10
#define BESTCOMBO_X_OFFSET 100
#define TEXT_X_OFFSET 10
#define TICK_X_OFFSET 200
#define DELETE_X_OFFSET 250

#define CURRENTCOMBO_Y_OFFSET 70
#define BESTCOMBO_Y_OFFSET 70
#define TEXT_Y_OFFSET 10
#define TICK_Y_OFFSET 10
#define DELETE_Y_OFFSET 10

#define CURRENTCOMBO_WIDTH 50
#define BESTCOMBO_WIDTH 50
#define TEXT_WIDTH 200
#define TICK_WIDTH 30
#define DELETE_WIDTH 60

#define CURRENTCOMBO_HEIGHT 20
#define BESTCOMBO_HEIGHT 20
#define TICK_HEIGHT 30
#define DELETE_HEIGHT 30

#define CURRENTCOMBO_FONT_SIZE 10
#define BESTCOMBO_FONT_SIZE 10
#define TEXT_FONT_SIZE 32

#define TASK_NAME_CHAR_LIMIT 10

#define TASK_NAME_PLACEHOLDER @"Your task name"

#define SLIDE_ANIMATION_DURATION 1

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addNewTaskButton;
- (IBAction)slideViewIn:(id)sender;
- (IBAction)slideViewOut:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;

@property (weak, nonatomic) IBOutlet UIView *slidingView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (weak, nonatomic) IBOutlet UIButton *hugeInvisibleButton;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;
- (IBAction)createNewTask:(id)sender;
- (IBAction)hugeInvisibleButton:(id)sender;
- (IBAction)timeSet:(id)sender;
- (IBAction)toggleReminder:(id)sender;

@end
