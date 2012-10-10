//
//  ViewController.h
//  J
//
//  Created by Basheer Subei on 22.09.12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *topScreenTextView;
@property (weak, nonatomic) IBOutlet UIView *topScreenView;
- (IBAction)topScreenFade:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *topDzeiButton;
@property (weak, nonatomic) IBOutlet UITextView *overviewTextView;

@property (strong, nonatomic) NSMutableArray *overviewArray;

@property BOOL topScreenIsVisible;

- (IBAction)sendMail:(id)sender;


- (void)mailComposeController:(MFMailComposeViewController *)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;

@end
