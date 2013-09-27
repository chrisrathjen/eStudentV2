//
//  Eintrag+Create.m
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Eintrag+Create.h"

@implementation Eintrag (Create)
+ (Eintrag *)CreateEintragWithTitle:(NSString *)title
                                art:(NSString *)art
                        isBestanden:(BOOL)bestanden
                          isBenotet:(BOOL)benotet
                                 cp:(NSNumber *)cp
                               note:(NSNumber *)note
                         inSemester:(Semester *)semester
                      inStudiengang:(Studiengang *)studiengang
                   inManagedContext:(NSManagedObjectContext *)context
{
    Eintrag *aEintrag = [NSEntityDescription insertNewObjectForEntityForName:@"Eintrag" inManagedObjectContext:context];
    
    aEintrag.titel = title;
    aEintrag.art = art;
    aEintrag.bestanden = [NSNumber numberWithBool:bestanden];
    aEintrag.benotet = [NSNumber numberWithBool:benotet];
    aEintrag.cp = cp;
    aEintrag.note = note;
    aEintrag.semester = semester;
    aEintrag.studiengang = studiengang;
    
    return aEintrag;
}

@end
