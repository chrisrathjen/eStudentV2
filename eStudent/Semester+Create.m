//
//  Semester+Create.m
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Semester+Create.h"

@implementation Semester (Create)
+(Semester *)CreateSemesterWithName:(NSString *)name
                   inManagedContext:(NSManagedObjectContext *)context{
    Semester *aSemester = [NSEntityDescription insertNewObjectForEntityForName:@"Semester" inManagedObjectContext:context];
    
    aSemester.name = name;
    
    return aSemester;
}
@end
