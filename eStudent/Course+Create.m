//
//  Course+Create.m
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Course+Create.h"

@implementation Course (Create)
+ (Course *)createCourseWithTitle:(NSString *)title
                              url:(NSString *)url
                           inTerm:(Term *)aTerm
                 inManagedContext:(NSManagedObjectContext *)context
{
    Course *aCourse = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:context];
    
    aCourse.title = title;
    aCourse.url = url;
    aCourse.semester = aTerm;

    return aCourse;
}
@end
