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

@interface TMPKriterium : NSObject

@property (nonatomic,strong)NSDate *dueDate;
@property (nonatomic,strong)NSString *name;
@property (nonatomic)BOOL completed;

- (TMPKriterium *)initWithName:(NSString *)name isCompleted:(BOOL)completed dueDate:(NSDate *)date;
- (Kriterium *)addSelfToDatabaseForEintrag:(Eintrag *)eintrag;

@end
