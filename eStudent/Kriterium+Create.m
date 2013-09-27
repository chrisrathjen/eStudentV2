//
//  Kriterium+Create.m
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Kriterium+Create.h"

@implementation Kriterium (Create)
+(Kriterium *)CreateKriteriumWithName:(NSString *)name
                           isErledigt:(BOOL)erledigt
                                 date:(NSDate *)date
                           forEintrag:(Eintrag *)eintrag
                     inManagedContext:(NSManagedObjectContext *)context
{
    Kriterium *aKriterium = [NSEntityDescription insertNewObjectForEntityForName:@"Kriterium" inManagedObjectContext:context];
    
    aKriterium.name = name;
    aKriterium.erledigt = [NSNumber numberWithBool:erledigt];
    aKriterium.date = date;
    aKriterium.eintrag = eintrag;
    
    return aKriterium;
}
@end
