//
//  Lecturer+Create.h
//  estudent
//
//  Created by Christian Rathjen on 11/7/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Lecturer.h"

@interface Lecturer (Create)
+ (Lecturer *)createLecturerWithTitle:(NSString *)title
                     inManagedContext:(NSManagedObjectContext *)context;

@end
