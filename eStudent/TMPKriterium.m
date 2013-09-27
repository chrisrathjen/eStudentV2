//
//  TMPKriterium.m
//  eStudent
//
//  Created by Nicolas Autzen on 18.03.13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import "TMPKriterium.h"
#import "CoreDataDataManager.h"

@implementation TMPKriterium

@synthesize dueDate = _dueDate;
@synthesize name = _name;
@synthesize completed = _completed;

- (TMPKriterium *)initWithName:(NSString *)name isCompleted:(BOOL)completed dueDate:(NSDate *)date
{
    self = [super init];
    if (self)
    {
        _dueDate = date;
        _name = name;
        _completed = completed;
    }
    
    return self;
}

//Der Datenmanager speichert ein Kriterium in der Datenbank über das TMPKriterium.
- (Kriterium *)addSelfToDatabaseForEintrag:(Eintrag *)eintrag
{
    return [[CoreDataDataManager sharedInstance] createKriteriumWithName:_name isErledigt:_completed date:_dueDate forEintrag:eintrag];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@\nErledigt: %i\nFälligleitsdatum: %@", _name, _completed, _dueDate];
}

@end