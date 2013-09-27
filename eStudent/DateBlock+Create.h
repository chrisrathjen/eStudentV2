//
//  DateBlock+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "DateBlock.h"

@interface DateBlock (Create)

+ (DateBlock *)createDateBlockWithRoom:(NSString *)room
                             startTime:(NSString *)startTime
                              stopTime:(NSString *)stopTime
                             startDate:(NSDate *)startDate
                              stopDate:(NSDate *)stopDate
                        repeatModifier:(NSNumber *)modifier
                               lecture:(Lecture *)aLecture
                      inManagedContext:(NSManagedObjectContext *)context;


@end
