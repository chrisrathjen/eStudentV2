//
//  Date+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Date.h"

@interface Date (Create)
+ (Date *)createDateWithDateBlock:(DateBlock *)aDateBlock
                        dateComps:(NSDictionary *)dateComps
                        startTime:(NSString *)startTime
                         stopTime:(NSString *)stopTime
                           active:(BOOL)active
                       forLecture:(Lecture *)aLecture
                 inManagedContext:(NSManagedObjectContext *)context;

@end
