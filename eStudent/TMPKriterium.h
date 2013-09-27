//
//  TMPKriterium.h
//  eStudent
//
//  Created by Nicolas Autzen on 18.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Kriterium;
@class Eintrag;

//Repräsentiert das temporäre Kriterium.
@interface TMPKriterium : NSObject

@property (nonatomic,strong)NSDate *dueDate;
@property (nonatomic,strong)NSString *name;
@property (nonatomic)BOOL completed;

//Der übeschriebene Intializer.
- (TMPKriterium *)initWithName:(NSString *)name isCompleted:(BOOL)completed dueDate:(NSDate *)date;
//Erstellt aus einem temporären Kriterium einen Eintrag in der Datenbank, über den Datenmanager.
- (Kriterium *)addSelfToDatabaseForEintrag:(Eintrag *)eintrag;

@end
