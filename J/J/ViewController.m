//
//  ViewController.m
//  J
//
//  Created by Basheer Subei on 22.09.12.
//  Copyright (c) 2012 Basheer Subei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize topScreenIsVisible;

- (void)dismissKeyboard
{
    [self.topScreenTextView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    [self setTopScreenIsVisible:YES];
    
    // set up (tap recognizer for the infoView)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setNumberOfTapsRequired:1];
    [self.topScreenView addGestureRecognizer:tap];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopScreenTextView:nil];
    [self setTopScreenView:nil];
    [super viewDidUnload];
}

// fades the topScreen in and out
- (IBAction)topScreenFade:(id)sender {
    
    // if the topScreen is already visible, then fade out
    if (topScreenIsVisible) {

        //fade out. Method that animates whatever is in the ^(void) block (setting alpha to zero in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:0.0];
        } completion:^(BOOL finished){}// completion block is empty in this case
         ];// if we put sthg there, it would be performed after animation is completed
        
        // don't forget to set the bool value to NO so that it can fade back in on next button tap.
        [self setTopScreenIsVisible:NO];
        
        // if topScreen is not visible, then fade it in
    } else{

        //fade in. Method that animates whatever is in the ^(void) block (setting alpha to one in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:1.0];
        } completion:^(BOOL finished){} // completion block is empty in this case
         ];                             // if we put sthg there, it would be performed after animation is completed
        
        // don't forget to set the bool value to YES so that it can fade back out on next button tap.
        [self setTopScreenIsVisible:YES];
    } //end if

}// end topScreenFade:

@end
