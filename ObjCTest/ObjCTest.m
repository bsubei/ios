#import <Foundation/Foundation.h>
#import "Student.h"
int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSDate *myDateObject = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    NSString *myString = [[NSString alloc] initWithString:[myDateObject description]];
	
	Student *firstKid = [[Student alloc] init];
	
	[firstKid setFirstName: @"basheer"];
	[firstKid setAge:20];
	[firstKid setLastName: @"subei"];
	[firstKid setGPA:3.99];
	
	
	
	
	// insert code here...
    
	NSLog(@"Hello, World!");
    
	NSLog(@"The date is: %@", myString);
	
	[firstKid displayInfo];
	
	[pool drain];
    return 0;
}
