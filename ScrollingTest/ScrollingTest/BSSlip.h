//
//  BSSlip.h
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

// GLOBAL constants

//extern NSString const *SLIP_IMAGE_NAME;
extern NSInteger const SLIP_FRAME_WIDTH;
extern NSInteger const SLIP_FRAME_HEIGHT;




@interface BSSlip : UIView



@property (strong, nonatomic) UIImageView *imageView; // will hold the slip image

@property (strong, nonatomic) UITextField *textField; // will hold textField (like textbox)

@property (strong, nonatomic) UIButton *moveToTopButton; //moves slip to top

@property (strong, nonatomic) UIButton *shredMeButton; //shreds slip

@property (strong, nonatomic) ViewController *callingViewController;

@property NSInteger FrameX; // Xcoordinate of slip frame
@property NSInteger FrameY; // Ycoordinate of slip frame
@property NSInteger slipIndex; // location in allSlips array


- (id)initWithFrame:(CGRect)frame withIndex:(NSInteger)index withCaller:(id)caller;

- (void)createButtonsForSlip;


@end

