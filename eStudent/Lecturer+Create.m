//
//  Lecturer+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Lecturer+Create.h"

@implementation Lecturer (Create)
+ (Lecturer *)createLecturerWithTitle:(NSString *)title
                     inManagedContext:(NSManagedObjectContext *)context
{
    Lecturer *aLecturer = [NSEntityDescription insertNewObjectForEntityForName:@"Lecturer" inManagedObjectContext:context];
    
    aLecturer.title = title;
    
    return aLecturer;
}
@end
