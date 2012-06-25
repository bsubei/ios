//
//  BSSlip.h
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// GLOBAL constants

//extern NSString const *SLIP_IMAGE_NAME;
extern NSInteger const SLIP_FRAME_WIDTH;
extern NSInteger const SLIP_FRAME_HEIGHT;




@interface BSSlip : UIView



@property (strong, nonatomic) IBOutlet UIImageView *imageView; // will hold the slip image

@property (strong, nonatomic) IBOutlet UITextView *textView; // will hold textView (like textbox)

@property NSInteger FrameX; // Xcoordinate of slip frame
@property NSInteger FrameY; // Ycoordinate of slip frame

@end

