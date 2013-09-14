//
//  Lecture+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Lecture+Create.h"

@implementation Lecture (Create)
+ (Lecture *)createLectureWithTitle:(NSString *)title
                                vak:(NSString *)vak
                                 cp:(NSNumber *)cp
                               type:(NSString *)type
                   activeInSchedule:(BOOL)active
                           inCourse:(Course *)aCourse
                   inManagedContext:(NSManagedObjectContext *)context
{
    Lecture *aLecture = [NSEntityDescription insertNewObjectForEntityForName:@"Lecture" inManagedObjectContext:context];
    
    aLecture.title = title;
    aLecture.vak = vak;
    aLecture.cp = cp;
    aLecture.type = type;
    aLecture.activeInSchedule = [NSNumber numberWithBool:active];
    aLecture.course = aCourse;
    
    return aLecture;
}
@end
