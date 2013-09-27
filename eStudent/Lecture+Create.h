//
//  Lecture+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Lecture.h"

@interface Lecture (Create)
+ (Lecture *)createLectureWithTitle:(NSString *)title
                                vak:(NSString *)vak
                                 cp:(NSNumber *)cp
                               type:(NSString *)type
                   activeInSchedule:(BOOL)active
                           inCourse:(Course *)aCourse
                 inManagedContext:(NSManagedObjectContext *)context;

@end
