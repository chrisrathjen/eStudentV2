//
//  Kriterium.h
//  estudent
//
//  Created by Christian Rathjen on 22/9/13.
//  Copyright (c) 2013 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eintrag;

@interface Kriterium : NSManagedObject

@property (nonatomic, retain) NSString * calendarItemIdentifier;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * erledigt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Eintrag *eintrag;

@end
