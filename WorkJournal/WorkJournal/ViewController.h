//
//  ViewController.h
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 Lock 'n' Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *todayTextView;
@property (strong, nonatomic) IBOutlet UITextView *overviewTextView;

- (IBAction)dismissKeyboardButton:(id)sender;
- (IBAction)optionsButton:(id)sender;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
