//
//  Course+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Course.h"

@interface Course (Create)
+ (Course *)createCourseWithTitle:(NSString *)title
                              url:(NSString *)url
                       inTerm:(Term *)aTerm
                 inManagedContext:(NSManagedObjectContext *)context;


@end
