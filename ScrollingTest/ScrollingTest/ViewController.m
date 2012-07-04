//
//  ViewController.m
//  ScrollingTest
//
//  Created by Basheer Subei on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BSSlip.h"
#import "AppDelegate.h"

@implementation ViewController

@synthesize dismissKeyboardOutlet;
@synthesize scrollView;
@synthesize backgroundImage;
@synthesize allSlips;

int slipBeingEdited = -1; // -1 signifies slip is NOT being edited currently
CALayer *theLayer;


// TODO read more about memory warning (app must be lite on memory)
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Saving and loading data

- (NSString *) saveFilePath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"savedData.plist"];
    
}
- (void) saveData
{
    // new array
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];

    //save every text string in allSlips to new array
    // IMPORTANT skip first top blank slip (explains i=1)
    for (int i=1; i<[allSlips count]; i++) {
        // checks the textData
        NSString *textData = [[[allSlips objectAtIndex:i] textField] text];
        if (textData == nil) {
            NSLog(@"can't save nil!");
            return;
        }
        // adds the text into the new array
        [dataToSave addObject: textData];
    }
    //writes text data to file
    [dataToSave writeToFile:[self saveFilePath] atomically:YES];
    
    //TODO life cycle debugging
    NSLog(@"end of saveData");

}
- (void) loadData
{

        
    //TODO need to check for invalid file path to avoid exceptions
    //if file doesn't exist, return
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self saveFilePath]]) {
        return;
    }
     
    //read in data
    NSArray *dataToLoad = [[NSArray alloc] initWithContentsOfFile:[self saveFilePath]];
    
    
    //TODO ? check that [dataToLoad count] + 1 == [allSlips count]
    
    //go through each text string in data, and make a slip for it
        // IMPORTANT skip first top blank slip (explains i+1)
    for (int i=0; i<[dataToLoad count]; i++) {
        //create a new slip
        [self createNewSlipAtIndex:[allSlips count]];
        //change the text on that new slip
        [[[allSlips lastObject] textField] setText:[dataToLoad objectAtIndex:i]];
    }
    

    //TODO life cycle debugging
    NSLog(@"end of loadData");
}

#pragma mark - Creating and Destroying Slips

// method that deletes last slip and updates scroll
// TODO transform this method to one that deletes specified slips (not just last)
- (void)shredSlip:(int)slipIndex
{

    
    // check no slips to shred or incorrect parameter
    if ([allSlips count] == 0 || slipIndex >= [allSlips count] || slipIndex < 0) {
        //TODO debugging
        NSLog(@"WTF? %i", slipIndex);
        return;
    }
    
    
    //TODO debugging text acquisition
    NSLog([[[allSlips objectAtIndex:slipIndex] textField] text], nil);
    
    // create a reference to the slip that's to be shredded
    BSSlip *thisSlip = [allSlips objectAtIndex:slipIndex];
    
    //remove slip from view
    [thisSlip removeFromSuperview];

    // remove slip from array
    [allSlips removeObjectAtIndex:slipIndex];
    //update scrollView
    [self updateScrollViewContentSize];
    
    //update dismissKeyboard size
    [self updateDismissKeyboardButtonSize];

    [self updateIndicesForAllSlips];
    
    //check if a slip is currently being edited and dismiss its keyboard
    [self dismissCurrentSlipKeyboard];
    
    //update all slips (if not last one deleted)
    [self updateSlipsInView];

    
}

// creates a new slip object, then adds it to allSlips array, then adds it as subview
// ***(assumes allSlips is initialized)*** and is private and so not in .h file
// slip already has ready imageView and (soon) textField
- (void)createNewSlipAtIndex: (int)index
{

    //creating newslip (uses getSlipFrame to return frame based on position in allSlips array)
    // passes in what index this slip is in and passes in the caller (self) 
    BSSlip *newSlip = [ [BSSlip alloc]initWithFrame: [self getSlipFrame: index] withIndex:index withCaller: self];
    
    // add it to array
    [allSlips insertObject:newSlip atIndex: index];
    [self updateIndicesForAllSlips];
    [self updateSlipsInView]; 
    
    //add new slip to scrollView 
    [scrollView addSubview:newSlip];
    
    //update as more slips are added
    [self updateScrollViewContentSize];
    [self updateDismissKeyboardButtonSize];
    


}


#pragma mark - Updating Methods

//  update slipIndex of rearranged slips // TODO need to do this in its own thread
- (void)updateIndicesForAllSlips
{
        for (int i =0; i<[allSlips count]; i++) {
        [[[self allSlips] objectAtIndex:i] setSlipIndex:i];    
    }
}


//method that moves slip to top (becomes first)
- (void)moveSlipToTop:(NSInteger)index
{
    //check if a slip is currently being edited and dismiss its keyboard
    [self dismissCurrentSlipKeyboard];
    
    //do nothing if slip is already top
    // and check for crazy values that cause exceptions
    if(index > 1 && index < [allSlips count]){
        // get current slip
        BSSlip *currentSlip = [[self allSlips] objectAtIndex:index];
        //insert it at top
        [allSlips insertObject:currentSlip atIndex:1];
        //remove old instance of current slip
        [allSlips removeObjectAtIndex:index+1 ];
        

        [self updateIndicesForAllSlips];
        
        // re(draws) all slips
        [self updateSlipsInView];
    }
}

- (void)updateDismissKeyboardButtonSize
{
    
    //resizes dismiss Keyboard button //TODO tweak this along with above
    [[self dismissKeyboardOutlet] setFrame:CGRectMake(0,0,
                                                      scrollView.frame.size.width
                                                      , scrollView.frame.size.height* ([allSlips count] /3.0) )];
    
}

// called whenever slips are created or shredded
// TODO tweak these values same as in createNewSlip (maybe use constants for slip size and spacing)
// TODO see if we want this animated!!!
- (void)updateScrollViewContentSize
{
    
    //animation description (like opening tag)  //TODO tweak animation values
    [UIView beginAnimations:@"MoveAndStrech" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.scrollView setContentSize:CGSizeMake(
                                               scrollView.frame.size.width
                                               , scrollView.frame.size.height* ([allSlips count] /5.0) )];
    
    // perform animations (like closing tag)
    [UIView commitAnimations];

}

// TODO tweak animations on this
// method that updates slip locations and re(moves) in view
- (void)updateSlipsInView
{
    // for every slip 
    for (int i=0; i<[allSlips count]; i++) {
        
        //get reference to current slip
        BSSlip *currentSlip = [allSlips objectAtIndex:i];
        
        //get its new frame
        CGRect newFrame = [self getSlipFrame:i];
        //set that slip's frameX to be the x we got from newFrame
        [ currentSlip setFrameX:newFrame.origin.x];
        //set that slip's frameY to be the y we got from newFrame
        [currentSlip setFrameY:newFrame.origin.y];
        
        
        //animation description (like opening tag)  //TODO tweak animation values
        [UIView beginAnimations:@"MoveAndStrech" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // D'OH!! so stupid! how could i have missed ACTUALLY CHANGING THE FRAME of each slips?
        [currentSlip setFrame:CGRectMake([currentSlip FrameX], [currentSlip FrameY], SLIP_FRAME_WIDTH, SLIP_FRAME_HEIGHT)];
        
        // perform animations (like closing tag)
        [UIView commitAnimations];
        
    } // end for loop
    
}


#pragma mark - Helper Methods

// called in appDidFinishLaunchingWithOptions (TODO call when loading data in appDidEnterForeground???)
- (void)initializeAllSlipsArray
{
    allSlips = [[NSMutableArray alloc]init];
}


/*
//enables all slip buttons (not used anymore)
- (void)enableAllButtons
{
    for (int i=0; i<[allSlips count]; i++) {
        //enables moveToTopButtons
        [[[allSlips objectAtIndex:i] moveToTopButton] setEnabled:YES];
        //enables shred buttons
        [[[allSlips objectAtIndex:i] shredMeButton] setEnabled:YES];
    }
}

//disables all slip buttons (not used anymore)
- (void)disableAllButtons
{
    for (int i=0; i<[allSlips count]; i++) {
        //enables moveToTopButtons
        [[[allSlips objectAtIndex:i] moveToTopButton] setEnabled:NO];
        //enables shred buttons
        [[[allSlips objectAtIndex:i] shredMeButton] setEnabled:NO];
    }
}
*/
 


// returns frame of slip depending on its order in allSlips array
// created because it will be reused in updateSlipsInView & in createNewSlip
- (CGRect)getSlipFrame:(NSInteger)index
{
    return CGRectMake(20
                      , 30 + (SLIP_FRAME_HEIGHT+ 20)*  index //TODO tweak AND store this somehow
                      , SLIP_FRAME_WIDTH
                      , SLIP_FRAME_HEIGHT);
}

//dismiss a slip's keyboard
- (void)dismissCurrentSlipKeyboard
{
    //check for valid slip
    if (slipBeingEdited >= 0) {
        // dismiss that slip's keyboard
        [[[allSlips objectAtIndex:slipBeingEdited] textField] resignFirstResponder];
    }

}

#pragma mark - Buttons
// button to dismiss keyboard
- (IBAction)invisibleDismissKeyboardButton:(id)sender {
    /*
    //change pos
    theLayer.position=CGPointMake(100.0f,300.0f);
    theLayer.bounds=CGRectMake(100.0f,300.0f,100.0f,100.0f);
    */
    [self saveData];
    
    [self dismissCurrentSlipKeyboard];
}
// button for testing 
- (IBAction)shredSlipButton:(id)sender 
{
    [self shredSlip:0];
}

// button for testing (adds new slip; update taken care of inside createNewSlip:)
- (IBAction)newSlipButton:(id)sender
{
//    NSLog(@"creating with index: %i", [allSlips count]);
    [self createNewSlipAtIndex:[allSlips count]];
    
}

#pragma mark - Delegate Methods

// called when user first starts editing a textField 
//TODO make it pass the slipIndex so that dismissKeyboard button knows who's slip to resignFirstResponder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    //check that we're dealing with slip textFields
    if ([textField.superview isKindOfClass:([BSSlip class])] ) {
        

        
        
        //enable the dismissKeyboard big invisible button
            [[self dismissKeyboardOutlet] setEnabled:YES];
    
        //extract slipIndex of this slip (the toughest line of code in this app)
        int index = [(BSSlip *)textField.superview slipIndex];
        
        // set the index of the slip being edited
        slipBeingEdited = index;
        

        
        //TODO fix prob where user can start editing (we get correct index), then
        // user deletes prev slip, but index is not updated
        //didBeginEditing (disable buttons)
        //didEndEditing (re-enable buttons)
//        [self disableAllButtons];
        
        //TODO, watch for the case when user is editing a slip, then hits the empty 'create-a-new-slip' slip.
        // in this case, i must reset the slipBeingEdited upon creation of new slip
        
        //TODO alternative to disabling buttons and gestures:  (DONE)
        // when button is pressed (or gesture), if slipBeingEdited is not -1 (i.e. the slip is being edited),
        // then resign first responder using slipBeingEdited and then continue on with action.
        
    }
    
   
}

// called after the keyboard is dismissed
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    

    
    //check that we're dealing with slip textFields
    if ([textField.superview isKindOfClass:([BSSlip class])] ) {
        
        //TODO handle first blank top slip
        
        //extract slipIndex of this slip (the toughest line of code in this app)
        int index = [(BSSlip *)textField.superview slipIndex];
        
        //if we're editing the first slip
        if(index==0)
        {
        //then create a new slip at top to replace it IF it's not blank   
            if([[textField text] length] > 0)
            {
                [self createNewSlipAtIndex:0];
                //place it above it (for sliding animation)
                [scrollView bringSubviewToFront:textField.superview];
                //create buttons for our 'promoted' slip
                [(BSSlip *)textField.superview createButtonsForSlip];
            }
        
        
        }
        slipBeingEdited = -1; // set so that there is no slip being edited
        //disable the big invisible button
        [[self dismissKeyboardOutlet] setEnabled:NO];
        
    }
    

}

// called when user hits return key (returning a yes makes it act default)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //init the array for all slips
    [self initializeAllSlipsArray];

    
    // setting initial ContentSize of scrollView (diff from frame size) and making it transparent 
    [self updateScrollViewContentSize];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    // loading the scrollView as a subview of root view
    [self.view addSubview:scrollView];
    
    //TODO fix this:put dismissKeyboard back
    [scrollView sendSubviewToBack:dismissKeyboardOutlet];
    
    //start off thiw the dismiss button being disabled (enabled when a slip is being edited)
    [[self dismissKeyboardOutlet] setEnabled:NO];
    
    //creates first blank slip at top
    [self createNewSlipAtIndex:0];
    
    //load data if file exists
    [self loadData];
    
    //TODO life cycle debugging
    NSLog(@"end of viewDidLoad");

/*
    //TODO testing Core Animation

    
    // create the layer
    theLayer=[CALayer layer];
    
    // set the contents property to a CGImageRef
    // specified by theImage (loaded elsewhere)
    theLayer.contents= (id)[[[UIImage alloc]initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"slip" ofType:@"png"]] CGImage];
    
    //set the bounds and position
    theLayer.position=CGPointMake(50.0f,50.0f);
    theLayer.bounds=CGRectMake(50.0f,50.0f,100.0f,100.0f);
    
    //add to view
//    [[[allSlips objectAtIndex:0] layer] addSublayer:theLayer];
*/
}


// TODO watch this (maybe unload everything in allSlips? or do that after enter background or quit)
// when is this called? when is viewDidLoad called?
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setBackgroundImage:nil];
    [self setDismissKeyboardOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    //TODO life cycle debugging
    NSLog(@"end of viewDidUnload");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
