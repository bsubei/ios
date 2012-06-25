//
//  ViewController.h
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //responsible for scrolling (is a parent view of all slips)
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage; // not a subView of scrollView (background doesn't scroll)
@property (strong, nonatomic) NSMutableArray *allSlips; //holds all slip objects

- (IBAction)newSlipButton:(id)sender;
- (void)initializeAllSlipsArray;

@end
