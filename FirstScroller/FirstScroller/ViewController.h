//
//  ViewController.h
//  FirstScroller
//
//  Created by Basheer Subei on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{

    IBOutlet UIView *mainView;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIView *ScrollableArea;
    __weak IBOutlet UIImageView *ImageView;
//IBOutlet UIScrollView *scrollView1;
}

//@property (nonatomic, retain) UIView *scrollView1;

@end
