//
//  Studiengang+Create.h
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Studiengang.h"

@interface Studiengang (Create)
+(Studiengang *)CreateStudiengangWithName:(NSString *)name
                                abschluss:(NSString *)abschluss
                                       cp:(NSNumber *)cp
                           erstesFachsemester:(Semester *)semester
                         inManagedContext:(NSManagedObjectContext *)context;

@end
