//
//  Student.h
//  ObjCTest
//
//  Created by Basheer Subei on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Student : NSObject

@property int age;
@property double GPA;
@property NSString *firstName;
@property NSString *lastName;



- (void) displayInfo;

@end
