//
//  ViewController.h
//  firstApp
//
//  Created by Basheer Subei on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)SelectDate:(id)sender;
- (IBAction)ToggleDate:(id)sender;
- (IBAction)Incrementer:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *Label;


@property (weak, nonatomic) IBOutlet UIStepper *Incrementer;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePicker;
@property (weak, nonatomic) IBOutlet UIButton *Button;


@end
