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

#define TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT @"Enter today's journal here..."

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

    //set delegate for topScreenTextView so that we can intercept textViewDidChange: calls and others
    [[self topScreenTextView]setDelegate:self];
    
    //set default placeholder text and color for topScreenTextView
    [self.topScreenTextView setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
    [self.topScreenTextView setTextColor:[UIColor grayColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopScreenTextView:nil];
    [self setTopScreenView:nil];
    [self setDzeiButton:nil];
    [super viewDidUnload];
}

// called whenever a textView wants to begin editing (return YES to allow editing and NO to disallow editing and ignore the request)
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    // if text is default, then change color to normal and delete the text
    if ([self.topScreenTextView.text isEqualToString:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT]) {
        
        [self.topScreenTextView setText:@""];
        [self.topScreenTextView setTextColor:[UIColor darkTextColor]];
    }
    
    // return yes (to allow editing; kb comes up)
    return YES;
}// end textViewShouldBeginEditing:

// called whenever textView is about to end editing (return YES to allow so that it resigns firstresponder and NO to keep it firstResponder)
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    // if text is left empty, then reset it to default text and light color
    if ([self.topScreenTextView.text isEqualToString:@""]) {
        
        [self.topScreenTextView setText:TOP_SCREEN_TEXT_VIEW_PLACEHOLDER_TEXT];
        [self.topScreenTextView setTextColor:[UIColor grayColor]];
    }
    
    
    // return yes (to allow resign first responder)
    return YES;
}// end textViewShouldEndEditing:

// disables and enables the dzei button
- (void)toggleButtonEnabled
{
    if([[self dzeiButton]isEnabled])
        [[self dzeiButton]setEnabled:NO];
    else
        [[self dzeiButton]setEnabled:YES];
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
        
        //disable the dzei button
        [self toggleButtonEnabled];
        // then re-enable it after a delay
        [self performSelector:@selector(toggleButtonEnabled) withObject:nil afterDelay:1.2];
        
        // don't forget to set the bool value to NO so that it can fade back in on next button tap.
        [self setTopScreenIsVisible:NO];
        
        // if topScreen is not visible, then fade it in
    } else{

        //fade in. Method that animates whatever is in the ^(void) block (setting alpha to one in this case)
        [UIView animateWithDuration:1 animations:^(void){
            [[self topScreenView] setAlpha:1.0];
        } completion:^(BOOL finished){} // completion block is empty in this case
         ];                             // if we put sthg there, it would be performed after animation is completed

        //disable the dzei button
        [self toggleButtonEnabled];
        // then re-enable it after a delay
        [self performSelector:@selector(toggleButtonEnabled) withObject:nil afterDelay:1.2];
        
        // don't forget to set the bool value to YES so that it can fade back out on next button tap.
        [self setTopScreenIsVisible:YES];
    } //end if

}// end topScreenFade:

@end
