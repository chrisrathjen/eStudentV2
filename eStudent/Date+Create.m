//
//  Date+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Date+Create.h"

@implementation Date (Create)
+ (Date *)createDateWithDateBlock:(DateBlock *)aDateBlock
                             date:(NSDate *)date
                        startTime:(NSString *)startTime
                         stopTime:(NSString *)stopTime
                           active:(BOOL)active
                       forLecture:(Lecture *)aLecture
                 inManagedContext:(NSManagedObjectContext *)context

{
    Date *aDate = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:context];
    
    aDate.dateBlock = aDateBlock;
    aDate.lecture = aLecture;
    aDate.date = date;
    aDate.startTime = startTime;
    aDate.stopTime = stopTime;
    aDate.active = [NSNumber numberWithBool:active];
    
    return aDate;
}
@end
