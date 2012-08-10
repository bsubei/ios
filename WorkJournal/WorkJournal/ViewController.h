//
//  ViewController.h
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UITextViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *todayTextView;
@property (strong, nonatomic) IBOutlet UITextView *overviewTextView;
@property (strong, nonatomic) IBOutlet UIButton *dismissKeyBoardButton;

- (IBAction)dismissKeyboardButton:(id)sender;
- (IBAction)optionsButton:(id)sender;
- (IBAction)deleteSavedData:(id)sender;

// UITableViewDataSource protocol methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void) performUpdate;

@end
