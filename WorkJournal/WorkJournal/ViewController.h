//
//  ViewController.h
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *todayTextView;
@property (strong, nonatomic) IBOutlet UITextView *overviewTextView;
@property (strong, nonatomic) IBOutlet UIButton *dismissKeyBoardButton;
@property (strong, nonatomic) NSMutableArray *overviewArray;
@property (strong, nonatomic) IBOutlet UITableView *overviewTableView;


- (IBAction)dismissKeyboardButton:(id)sender;
- (IBAction)optionsButton:(id)sender;
- (IBAction)deleteSavedData:(id)sender;
//- (IBAction)pageControlClicked:(id)sender;

// UITableViewDataSource protocol methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
// UITableViewDelegate protocol method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
//- (void) performUpdateOnLoad;

@end
