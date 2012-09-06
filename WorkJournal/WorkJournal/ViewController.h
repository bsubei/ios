//
//  ViewController.h
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *dismissKeyBoardButton;
@property (strong, nonatomic) NSMutableArray *overviewArray;
@property (strong, nonatomic) IBOutlet UITableView *overviewTableView;
@property (strong, nonatomic) IBOutlet UIImageView *infoView;
@property (strong, nonatomic) IBOutlet UIButton *optionsButton;
- (IBAction)updateMeNow:(id)sender;


- (IBAction)dismissKeyboardButton:(id)sender;
- (IBAction)optionsButton:(id)sender;

// UITableViewDataSource protocol methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

// UITableViewDelegate protocol method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)textViewDidChange:(UITextView *)textView;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;


- (void)mailComposeController:(MFMailComposeViewController *)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;

@end
