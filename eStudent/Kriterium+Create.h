//
//  Kriterium+Create.h
//  eStudent
//
//  Created by Christian Rathjen on 16/2/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "Kriterium.h"

@interface Kriterium (Create)
+(Kriterium *)CreateKriteriumWithName:(NSString *)name
                           isErledigt:(BOOL)erledigt
                                 date:(NSDate *)date
                           forEintrag:(Eintrag *)eintrag
                     inManagedContext:(NSManagedObjectContext *)context;
@end
