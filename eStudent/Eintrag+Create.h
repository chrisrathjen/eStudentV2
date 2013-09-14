//
//  Eintrag+Create.h
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Eintrag.h"

@interface Eintrag (Create)
+ (Eintrag *)CreateEintragWithTitle:(NSString *)title
                                art:(NSString *)art
                        isBestanden:(BOOL)bestanden
                          isBenotet:(BOOL)benotet
                                 cp:(NSNumber *)cp
                               note:(NSNumber *)note
                         inSemester:(Semester *)semester
                      inStudiengang:(Studiengang *)studiengang
                   inManagedContext:(NSManagedObjectContext *)context;
@end
