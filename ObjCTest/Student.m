//
//  Student.m
//  ObjCTest
//
//  Created by Basheer Subei on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Student.h"


@implementation Student

@synthesize age, GPA, firstName, lastName;

- (void) displayInfo {
	NSLog(@"%@ %@ is %i years old and has a GPA of %f", [[self firstName] capitalizedString], [[self lastName] capitalizedString], [self age], [self GPA]);
}
@end
