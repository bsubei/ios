//
//  ViewController.h
//  shaker
//
//  Created by Basheer Subei on 10/3/12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *lockImage;
- (IBAction)shake:(id)sender;

@end
