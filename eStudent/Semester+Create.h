//
//  Semester+Create.h
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Semester.h"

@interface Semester (Create)
+(Semester *)CreateSemesterWithName:(NSString *)name
                   inManagedContext:(NSManagedObjectContext *)context;
@end
