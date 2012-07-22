//
//  ViewController.h
//  WorkJournal
//
//  Created by Basheer Subei on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *todayTextView;

- (IBAction)dismissKeyboardButton:(id)sender;
- (IBAction)optionsButton:(id)sender;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
@end
