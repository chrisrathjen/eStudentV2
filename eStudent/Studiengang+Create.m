//
//  Studiengang+Create.m
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Studiengang+Create.h"

@implementation Studiengang (Create)
+(Studiengang *)CreateStudiengangWithName:(NSString *)name
                                abschluss:(NSString *)abschluss
                                       cp:(NSNumber *)cp
                       erstesFachsemester:(Semester *)semester
                         inManagedContext:(NSManagedObjectContext *)context
{
    Studiengang *aStudiengang = [NSEntityDescription insertNewObjectForEntityForName:@"Studiengang" inManagedObjectContext:context];
    
    aStudiengang.name = name;
    aStudiengang.abschluss = abschluss;
    aStudiengang.cp = cp;
    aStudiengang.erstesFachsemester = semester;
    
    return aStudiengang;
}
@end
