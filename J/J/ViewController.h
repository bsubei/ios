//
//  ViewController.h
//  J
//
//  Created by Basheer Subei on 22.09.12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *topScreenTextView;
@property (weak, nonatomic) IBOutlet UIView *topScreenView;
- (IBAction)topScreenFade:(id)sender;

@property BOOL topScreenIsVisible;

@end
