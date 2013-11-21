//
//  DateBlock+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "DateBlock+Create.h"

@implementation DateBlock (Create)
+ (DateBlock *)createDateBlockWithRoom:(NSString *)room
                             startTime:(NSString *)startTime
                              stopTime:(NSString *)stopTime
                             startDate:(NSDate *)startDate
                              stopDate:(NSDate *)stopDate
                        repeatModifier:(NSNumber *)modifier
                                  type:(NSString *)type
                               lecture:(Lecture *)aLecture
                      inManagedContext:(NSManagedObjectContext *)context

{
    DateBlock *aDateBlock = [NSEntityDescription insertNewObjectForEntityForName:@"DateBlock" inManagedObjectContext:context];
    
    aDateBlock.room = room;
    aDateBlock.startTime = startTime;
    aDateBlock.stopTime = stopTime;
    aDateBlock.startDate = startDate;
    aDateBlock.stopDate = stopDate;
    aDateBlock.repeatModifier = modifier;
    aDateBlock.lecture = aLecture;
    aDateBlock.type = type;
    return aDateBlock;
}
@end
